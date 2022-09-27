from django import forms

from .models import Car,People,Transact

class PeopleModelChoiceField(forms.ModelChoiceField):
    def label_from_instance(self, obj):
        user_id = 'User id: ' + str(obj.user_id)
        coin = 'Coin: ' + str(obj.coin) + '$'
        return user_id + ' - ' + obj.last_name + '  ' + obj.first_name + ' - ' + coin

class CarModelChoiceField(forms.ModelChoiceField):
    def label_from_instance(self, obj):
        car_id = 'Car id: ' + str(obj.car_id)
        price = 'Price: ' + str(obj.price) + '$'
        owner = 'Owner id: ' + str(obj.owner.user_id) + ' - ' + obj.owner.last_name + '  ' + obj.owner.first_name + ' - ' + 'Coin: ' + str(obj.owner.coin)
        return car_id + ' - ' + obj.brand + ' - ' + obj.condition + ' - ' + obj.gearbox + ' - ' + price + ' || ' + owner
        
class people_insert_form(forms.Form):
	#user_id = models.AutoField(primary_key=True)
    first_name = forms.CharField(max_length=255)
    last_name = forms.CharField(max_length=255)
    dob = forms.DateField()
    sex = forms.CharField(max_length=1)
    address = forms.CharField(max_length=255)
    phone_number = forms.CharField(max_length=11)
    coin = forms.IntegerField()

class car_insert_form(forms.Form):
	owner = PeopleModelChoiceField(queryset = People.objects.all().order_by('user_id'))
	brand = forms.CharField(max_length=255)
	condition = forms.CharField(max_length=3)
	year = forms.IntegerField()
	gearbox = forms.CharField(max_length=10)
	price = forms.IntegerField()
	for_sale = forms.BooleanField()

class make_transaction_form(forms.Form):
    buyer = PeopleModelChoiceField(queryset = People.objects.all().order_by('user_id') )
    car = CarModelChoiceField(queryset = Car.objects.filter(for_sale = True).order_by('car_id') )