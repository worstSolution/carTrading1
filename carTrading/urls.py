"""carTrading URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from car.views import home_view,car_list_view,people_list_view,people_insert_view,people_name_search_view, \
                        people_detail_view, car_insert_view, car_brand_search_view, make_transaction_view,car_detail_view, \
                        trans_id_search_view, trans_buyer_name_search_view, trans_seller_name_search_view, trans_list_view, \
                        findcarwithgearbox_view, findcarwithcity_view, findcarwithcondition_view, findcarwithyear_view, \
                        findcarwithprice_view, findsalecar_view, showownedcars_view, finduserwithage_view, finduserwithcity_view, \
                        findtranswithcarid_view, updatecoin_view, findtranswithdate_view, findselltrans_view,findcarwithgearboxandcondition_view,\
                        findcarwithpriceandgearbox_view, show_list_buyer_view, show_list_seller_view
urlpatterns = [
    path('admin/', admin.site.urls),
    path('',home_view,name='home'),
    path('people/<int:user_id>/',people_detail_view,name='people_detail'),
    path('car/<int:car_id>/',car_detail_view,name='car-detail'),

    path('car-list/',car_list_view,name='car-list'),
    path('people-list/',people_list_view,name='people-list'),
    path('trans-list/',trans_list_view,name='trans-list'),
    path('show_list_buyer/',show_list_buyer_view,name='show_list_buyer'),
    path('show_list_seller/',show_list_seller_view,name='show_list_seller'),

    path('people-insert/',people_insert_view,name='people-insert'),
    path('car-insert/',car_insert_view,name='car-insert'),
    path('make-transaction/',make_transaction_view,name='make-transaction'),
    path('updatecoin/',updatecoin_view,name='updatecoin'),

    path('people-name-search/',people_name_search_view,name='people-name-search'),
    path('finduserwithage/',finduserwithage_view,name='finduserwithage'),
    path('finduserwithcity/',finduserwithcity_view,name='finduserwithcity'),
    
    
    path('car-brand-search/',car_brand_search_view,name='car-brand-search'),  
    path('findcarwithgearbox/',findcarwithgearbox_view,name='findcarwithgearbox'),
    path('findcarwithcity/',findcarwithcity_view,name='findcarwithcity'),
    path('findcarwithcondition/',findcarwithcondition_view,name='findcarwithcondition'),
    path('findcarwithyear/',findcarwithyear_view,name='findcarwithyear'),
    path('findcarwithprice/',findcarwithprice_view,name='findcarwithprice'),
    path('findsalecar/',findsalecar_view,name='findsalecar'),
    path('findcarwithgearboxandcondition/',findcarwithgearboxandcondition_view,name='findcarwithgearboxandcondition'),
    path('findcarwithpriceandgearbox/',findcarwithpriceandgearbox_view,name='findcarwithpriceandgearbox'),
    path('showownedcars/',showownedcars_view,name='showownedcars'), 
    
    path('findtranswithcarid/',findtranswithcarid_view,name='findtranswithcarid'),
    path('trans-id-search/',trans_id_search_view,name='trans-id-search'),
    path('trans-buyer-name-search/',trans_buyer_name_search_view,name='trans-buyer-name-search'),
    path('trans-seller-name-search/',trans_seller_name_search_view,name='trans-seller-name-search'),
    path('findtranswithdate/',findtranswithdate_view,name='findtranswithdate'),
    path('findselltrans/',findselltrans_view,name='findselltrans'),
    
]
