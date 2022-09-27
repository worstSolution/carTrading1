from django.contrib import admin
from .models import Car,People,Transact
# Register your models here.
admin.site.register(Car)
admin.site.register(People)
admin.site.register(Transact)