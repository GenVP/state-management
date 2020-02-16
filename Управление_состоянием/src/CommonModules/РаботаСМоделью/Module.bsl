Функция НайтиЗначение(ТипЗначения, ВходящиеПараметры, ЗначениеПоУмолчанию, ОпределитьОднозначноеЗначение = Истина) Экспорт
	Перем Значение;
	Если ВходящиеПараметры.Свойство("Ссылка", Значение) Тогда
		Возврат Значение;
	КонецЕсли;
	Значение = ОбщийКлиентСервер.ПустаяСсылкаПоТипу(ТипЗначения);
	Запрос = Новый Запрос;
	ТекстЗапроса = РаботаСДаннымиВыбора.НастроитьЗапросОбработкиПолученияДанныхВыбора(Запрос, Значение.Метаданные().ПолноеИмя(),, ВходящиеПараметры, 1);
	СхемаЗапроса = Новый СхемаЗапроса;
	//  Проверка соответствия значения структуре параметров
	Если ЗначениеЗаполнено(ЗначениеПоУмолчанию) Тогда
		СхемаЗапроса.УстановитьТекстЗапроса(ТекстЗапроса);
		ОператорВыбрать = СхемаЗапроса.ПакетЗапросов[СхемаЗапроса.ПакетЗапросов.Количество()-1].Операторы[0];
		ОператорВыбрать.Отбор.Добавить("Источник.Ссылка = &ЗначениеПоУмолчанию");
		Запрос.Текст = СхемаЗапроса.ПолучитьТекстЗапроса();
		Запрос.УстановитьПараметр("ЗначениеПоУмолчанию", ЗначениеПоУмолчанию);
		Если НЕ Запрос.Выполнить().Пустой() Тогда
			Значение = ЗначениеПоУмолчанию;
		КонецЕсли;
	КонецЕсли;
	//  Заполнение пустого или сброшенного значения однозначным значением по структуре параметров
	Если ОпределитьОднозначноеЗначение И НЕ ЗначениеЗаполнено(Значение) Тогда
		СхемаЗапроса.УстановитьТекстЗапроса(ТекстЗапроса);
		ОператорВыбрать = СхемаЗапроса.ПакетЗапросов[СхемаЗапроса.ПакетЗапросов.Количество()-1].Операторы[0];
		ОператорВыбрать.КоличествоПолучаемыхЗаписей = 2;
		Запрос.Текст = СхемаЗапроса.ПолучитьТекстЗапроса();
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Количество() = 1 Тогда
			Выборка.Следующий();
			Значение = Выборка.Ссылка;
		КонецЕсли;
	КонецЕсли;
	Возврат Значение;
КонецФункции

Процедура РассчитатьПроизводныеПараметры(Контекст, Модель) Экспорт
	Перем ИмяРеквизита;
	Список = Новый СписокЗначений;
	Для Каждого ЭлементПараметра Из Модель.Параметры Цикл
		Параметр = ЭлементПараметра.Значение;
		Если НЕ Параметр.СохраняемыеДанные Тогда
			Список.Добавить(Параметр.Порядок, Параметр.Идентификатор);
		КонецЕсли;
	КонецЦикла;
	Список.СортироватьПоЗначению(НаправлениеСортировки.Убыв);
	Для Каждого ЭлементСписка Из Список Цикл
		Параметр = Модель.Параметры[ЭлементСписка.Представление];
		//  Это реквизит объекта или контекста
		Если Параметр.ЭтоЭлементКоллекции Тогда
			//  TODO: КА_ Добавить расчет производных параметров коллекции
		Иначе
			ВходящиеПараметры = РаботаСМодельюКлиентСервер.ПараметрыСвязей(Контекст, Модель, Параметр);
			РаботаСМодельюКлиентСервер.ЗаполнитьЗначение(Контекст, Модель, 
				РаботаСМодельюКлиентСервер.ПолучитьОбъектПараметра(Контекст, Модель, Параметр,, ИмяРеквизита)[ИмяРеквизита], 
				Параметр, ВходящиеПараметры);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция ЗначенияРеквизитов(Модель, Параметр, Реквизиты) Экспорт
	Возврат Справочники.Валюты.НайтиПоКоду("643");
КонецФункции

Функция ЗначениеРеквизита(Модель, Параметр, Реквизит) Экспорт
	Возврат Справочники.Валюты.НайтиПоКоду("643");
КонецФункции

Процедура ХранилищеЗначений(Контекст, Модель) Экспорт
	//  Определить все параметры, которые без пути и классифицировать их по таблицам хранения
	Таблицы = Новый Соответствие;
	Таблицы["ХранилищеЗначений"] = Новый Массив;
	Для Каждого ЭлементПараметра Из Модель.Параметры Цикл
		Параметр = ЭлементПараметра.Значение;
		Если Параметр.ПутьКДанным = "" Тогда
			Коллекция = "ХранилищеЗначений" + Параметр.Коллекция;
			Колонки = Таблицы[Коллекция];
			Если Колонки = Неопределено Тогда
				Колонки = Новый Массив;
				Таблицы[Коллекция] = Колонки;
			КонецЕсли;
			Если Параметр.Коллекция = "" Тогда
				Колонки.Добавить(Параметр.Идентификатор);
			Иначе
				Колонки.Добавить(СтрРазделить(Параметр.Идентификатор, ".")[1]);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	//  Создать таблицы хранения значений расчетных параметров. Для не табличных параметров такой таблицей выступает
	//  ХранилищеЗначений. Для табличных: ХранилищеЗначений%ИмяТаблицы%
	//  - ХранилищеЗначений - ТаблицаЗначений
	//  * Значение - Произвольный
	//  - ХранилищеЗначений_%ИмяТаблицы%
	//  * ИдентификаторСтроки - Строка(36)
	//  * %ИмяПараметраТаблицы% - Произвольный
	Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения") Тогда
		НовыеРеквизиты = Новый Массив;
		Для Каждого ЭлементТаблицы Из Таблицы Цикл
			НовыеРеквизиты.Добавить(Новый РеквизитФормы(ЭлементТаблицы.Ключ, Новый ОписаниеТипов("ТаблицаЗначений")));
			Если ЭлементТаблицы.Ключ = "ХранилищеЗначений" Тогда
				НовыеРеквизиты.Добавить(Новый РеквизитФормы("Параметр", ОбщегоНазначения.ОписаниеТипаСтрока(100), ЭлементТаблицы.Ключ));
				НовыеРеквизиты.Добавить(Новый РеквизитФормы("Значение", Новый ОписаниеТипов, ЭлементТаблицы.Ключ));
			Иначе
				НовыеРеквизиты.Добавить(Новый РеквизитФормы("ИдентификаторСтроки", ОбщегоНазначения.ОписаниеТипаСтрока(36), ЭлементТаблицы.Ключ));
				Для Каждого Колонка Из ЭлементТаблицы.Значение Цикл
		    		НовыеРеквизиты.Добавить(Новый РеквизитФормы(Колонка, Новый ОписаниеТипов, ЭлементТаблицы.Ключ));
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
		Контекст.ИзменитьРеквизиты(НовыеРеквизиты);

		Для Каждого ЭлементТаблицы Из Таблицы Цикл
			ЗаполнитьЗначенияСвойств(Контекст[ЭлементТаблицы.Ключ].Добавить(), Новый Структура("Параметр, Значение", "Словарь", Новый ФиксированноеСоответствие(Новый Соответствие)));
		КонецЦикла;
				
		СтрокаЗначения = Контекст["ХранилищеЗначений"].Добавить();
		СтрокаЗначения.Параметр = "Модель";
		СтрокаЗначения.Значение = ОбщегоНазначения.ФиксированныеДанные(Модель);

		Словарь = Новый Соответствие;
		Словарь["Модель"] = 1;
		
		Параметры = Таблицы["ХранилищеЗначений"];
		Если Параметры <> Неопределено Тогда
			ИндексСтроки = 1;
			Для Каждого ИДПараметра Из Параметры Цикл
				ИндексСтроки = ИндексСтроки + 1;
				Словарь[ИДПараметра] = ИндексСтроки;
				СтрокаЗначения = Контекст["ХранилищеЗначений"].Добавить();
				СтрокаЗначения.Параметр = ИДПараметра;
			КонецЦикла;
		КонецЕсли;
		
		Контекст["ХранилищеЗначений"][0].Значение = Новый ФиксированноеСоответствие(Словарь);
						
	Иначе // создание таблиц значений в контексте объекта
		//TODO: КА_ Создать таблицы расчетных параметров в объекте
	КонецЕсли;
КонецПроцедуры
