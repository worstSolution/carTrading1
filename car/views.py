from django.shortcuts import render
from .models import Car,People,Transact
from .forms import people_insert_form, car_insert_form, make_transaction_form
from django.db import connection
from collections import namedtuple

from django.db.models import Max, Q
# Create your views here.

def namedtuplefetchall(cursor):
    "Return all rows from a cursor as a namedtuple"
    desc = cursor.description
    nt_result = namedtuple('Result', [col[0] for col in desc])
    return [nt_result(*row) for row in cursor.fetchall()]


def home_view(request,*args,**kwargs):
	context = {}
	return render(request,"home.html",context)

def car_list_view(request,*args,**kwargs):
	queryset = Car.objects.all().order_by('car_id')
	context = {'car_list' : queryset}
	return render(request,"car_list.html",context)

def people_list_view(request,*args,**kwargs):
	queryset = People.objects.all().order_by('user_id')
	context = {'people_list' : queryset}
	return render(request,"people_list.html",context)

def people_insert_view(request):
	form = people_insert_form()
	inserted = 0
	user_id_created = 0
	if request.method == 'POST':
		form = people_insert_form(request.POST)
		if form.is_valid():
			People.objects.create(**form.cleaned_data)
			form = people_insert_form()
			inserted = 1
			user_id_created = People.objects.aggregate(Max('user_id'))
		else:
			print(form.errors)
	context = {'form' : form, 'inserted' : inserted, 'user_id_created': user_id_created }
	return render(request,"people_insert.html",context)

def people_name_search_view(request,*args,**kwargs):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = 'not a name'
	people = People.objects.filter(Q(first_name__icontains = query) | Q(last_name__icontains = query)).order_by('user_id')
	context = {'query' : query, 'people' : people}
	return render(request,"people_name_search.html",context)

def people_detail_view(request,user_id):
	people = People.objects.get(user_id = user_id)
	with connection.cursor() as cursor:
		cursor.callproc('countsoldcars',[user_id])
		sold = namedtuplefetchall(cursor)
		cursor.callproc('countboughtcars',[user_id])
		bought = namedtuplefetchall(cursor)
		cursor.callproc('countownedcars',[user_id])
		own = namedtuplefetchall(cursor)
	sold_car = sold[0]
	bought_car = bought[0]
	own_car = own[0]
	print('hello')
	print(sold_car)
	context = { 'people': people, 'sold_car' : sold_car, 'bought_car' : bought_car, 'own_car' : own_car}
	return render(request,"people_detail.html",context)

def car_insert_view(request):
	form = car_insert_form()
	inserted = 0
	car_id_created = 0
	if request.method == 'POST':
		form = car_insert_form(request.POST)
		if form.is_valid():
			Car.objects.create(**form.cleaned_data)
			form = car_insert_form()
			inserted = 1
			car_id_created = Car.objects.aggregate(Max('car_id'))
		else:
			print(form.errors)
	context = {'form' : form, 'inserted' : inserted, 'car_id_created': car_id_created }
	return render(request,"car_insert.html",context)

def car_brand_search_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = 'not a name'
	people = Car.objects.filter(brand__icontains = query).order_by('car_id')
	context = {'query' : query, 'car_list' : people}
	return render(request,"car_brand_search.html",context)

def make_transaction_view(request):
	form = make_transaction_form()
	transacted = 0
	trans_id_created = 0
	if request.method == 'POST':
		form = make_transaction_form(request.POST)
		if form.is_valid():
			buyer = form.cleaned_data['buyer']
			car = form.cleaned_data['car']
			seller = car.owner
			if car.price > buyer.coin:
				context = {'form' : form, 'transacted' : transacted, 'trans_id_created': trans_id_created }
				return render(request,"make_transaction.html",context)
			seller.coin += car.price
			seller.save()
			buyer.coin -= car.price
			buyer.save()
			car.for_sale = False
			car.save()

			Transact.objects.create(**form.cleaned_data)
			transacted = 1

			form = make_transaction_form()
			
			trans_id_created = Transact.objects.aggregate(Max('trans_id'))
			print('success')
		else:
			print(form.errors)
	context = {'form' : form, 'transacted' : transacted, 'trans_id_created': trans_id_created }
	return render(request,"make_transaction.html",context)

def car_detail_view(request, car_id):
	car = Car.objects.get(car_id = car_id)
	context = { 'car': car }
	return render(request,"car_detail.html",context)

# tao view search transaction dua vao id va nguoi mua/ nguoi ban
def trans_id_search_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	trans = None
	if not query:
		context = {'trans' : trans}
		return render(request,"trans_id_search.html",context)
	trans = Transact.objects.filter(trans_id = query)
	context = {'trans' : trans}
	return render(request,"trans_id_search.html",context)

def trans_buyer_name_search_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	trans_list = None
	if not query:
		context = {'trans_list' : trans_list}
		return render(request,"trans_buyer_name_search.html",context)
	trans_list = Transact.objects.filter(Q(buyer__first_name__icontains = query) | Q(buyer__last_name__icontains = query)).order_by('trans_id')
	context = {'trans_list' : trans_list}
	return render(request,"trans_buyer_name_search.html",context)

def trans_seller_name_search_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	trans_list = None
	if not query:
		context = {'trans_list' : trans_list}
		return render(request,"trans_seller_name_search.html",context)
	trans_list = Transact.objects.filter(Q(seller__first_name__icontains = query) | Q(seller__last_name__icontains = query)).order_by('trans_id')
	context = {'trans_list' : trans_list}
	return render(request,"trans_seller_name_search.html",context)

def trans_list_view(request):
	queryset = Transact.objects.all().order_by('trans_id')
	context = {'trans_list' : queryset}
	return render(request,"trans_list.html",context)

def findcarwithgearbox_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = 'not a name'
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithgearbox',[query])
		car_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'car_list' : car_list}
	return render(request,"findcarwithgearbox.html",context)

def findcarwithgearbox_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = 'not a name'
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithgearbox',[query])
		car_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'car_list' : car_list}
	return render(request,"findcarwithgearbox.html",context)

def findcarwithcity_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = 'not a name'
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithcity',[query])
		car_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'car_list' : car_list}
	return render(request,"findcarwithcity.html",context)

def findcarwithcondition_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = 'not a name'
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithcondition',[query])
		car_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'car_list' : car_list}
	return render(request,"findcarwithcondition.html",context)

def findcarwithyear_view(request):
	query_dict = request.GET
	query1 = query_dict.get('q1')
	if not query1:
		query1 = -1
	query2 = query_dict.get('q2')
	if not query2:
		query2 = 0
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithyear',[query1, query2])
		car_list = namedtuplefetchall(cursor)
	context = {'query1' : query1, 'query2' : query2, 'car_list' : car_list}
	return render(request,"findcarwithyear.html",context)

def findcarwithprice_view(request):
	query_dict = request.GET
	query1 = query_dict.get('q1')
	if not query1:
		query1 = -1
	query2 = query_dict.get('q2')
	if not query2:
		query2 = 0
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithprice',[query1, query2])
		car_list = namedtuplefetchall(cursor)
	context = {'query1' : query1, 'query2' : query2, 'car_list' : car_list}
	return render(request,"findcarwithprice.html",context)

def findsalecar_view(request):
	with connection.cursor() as cursor:
		cursor.callproc('findsalecar')
		car_list = namedtuplefetchall(cursor)
		cursor.callproc('countsalecar')
		count = namedtuplefetchall(cursor)
	number = count[0][0]
	context = {'car_list' : car_list, 'number' : number}
	return render(request,"findsalecar.html",context)

def findcarwithgearboxandcondition_view(request):
	query_dict = request.GET
	query1 = query_dict.get('q1')
	if not query1:
		query1 = '0'
	query2 = query_dict.get('q2')
	if not query2:
		query2 = '0'
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithgearboxandcondition',[query1, query2])
		car_list = namedtuplefetchall(cursor)
	context = {'query1' : query1, 'query2' : query2, 'car_list' : car_list}
	return render(request,"findcarwithgearboxandcondition.html",context)

def findcarwithpriceandgearbox_view(request):
	query_dict = request.GET
	query1 = query_dict.get('q1')
	if not query1:
		query1 = 0
	query2 = query_dict.get('q2')
	if not query2:
		query2 = 0
	query3 = query_dict.get('q3')
	if not query2:
		query3 = '0'
	with connection.cursor() as cursor:
		cursor.callproc('findcarwithpriceandgearbox',[query1, query2, query3])
		car_list = namedtuplefetchall(cursor)
	context = {'query1' : query1, 'query2' : query2, 'car_list' : car_list}
	return render(request,"findcarwithpriceandgearbox.html",context)

def showownedcars_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = -1
	with connection.cursor() as cursor:
		cursor.callproc('showownedcars',[query])
		car_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'car_list' : car_list}
	return render(request,"showownedcars.html",context)

def finduserwithage_view(request):
	query_dict = request.GET
	query1 = query_dict.get('q1')
	if not query1:
		query1 = -1
	query2 = query_dict.get('q2')
	if not query2:
		query2 = 0
	with connection.cursor() as cursor:
		cursor.callproc('finduserwithage',[query1, query2])
		people_list = namedtuplefetchall(cursor)
	context = {'query1' : query1, 'query2' : query2, 'people_list' : people_list}
	return render(request,"finduserwithage.html",context)

def finduserwithcity_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = '0'
	with connection.cursor() as cursor:
		cursor.callproc('finduserwithcity',[query])
		people_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'people_list' : people_list}
	return render(request,"finduserwithcity.html",context)

def findtranswithcarid_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = '-1'
	with connection.cursor() as cursor:
		cursor.callproc('findtranswithcarid',[query])
		trans_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'trans_list' : trans_list}
	return render(request,"findtranswithcarid.html",context)

def findtranswithdate_view(request):
	query_dict = request.GET
	query1 = query_dict.get('q1')
	if not query1:
		query1 = '1-1-1970'
	query2 = query_dict.get('q2')
	if not query2:
		query2 = '2-1-1970'
	with connection.cursor() as cursor:
		cursor.callproc('findtranswithdate',[query1, query2])
		trans_list = namedtuplefetchall(cursor)
	context = {'query1' : query1, 'query2' : query2, 'trans_list' : trans_list}
	return render(request,"findtranswithdate.html",context)

def findselltrans_view(request):
	query_dict = request.GET
	query = query_dict.get('q')
	if not query:
		query = '-1'
	with connection.cursor() as cursor:
		cursor.callproc('findselltrans',[query])
		trans_list = namedtuplefetchall(cursor)
	context = {'query' : query, 'trans_list' : trans_list}
	return render(request,"findselltrans.html",context)

def updatecoin_view(request):
	query_dict = request.GET
	query1 = query_dict.get('q1')
	if not query1:
		query1 = 0
	query2 = query_dict.get('q2')
	if not query2 or query2 < '0':
		query2 = 0
	with connection.cursor() as cursor:
		check = cursor.callproc('updatecoin',[query1, query2])
	if not (query1 or query2):
		check = 0
	context = {'query1' : query1, 'query2' : query2, 'check' : check}
	return render(request,"updatecoin.html",context)

def show_list_buyer_view(request):
	with connection.cursor() as cursor:
		cursor.callproc('show_list_buyer')
		buyer_list = namedtuplefetchall(cursor)
	context = {'buyer_list' : buyer_list}
	return render(request,"show_list_buyer.html",context)

def show_list_seller_view(request):
	with connection.cursor() as cursor:
		cursor.callproc('show_list_seller')
		seller_list = namedtuplefetchall(cursor)
	context = {'seller_list' : seller_list}
	return render(request,"show_list_seller.html",context)