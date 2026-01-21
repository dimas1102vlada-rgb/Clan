import telebot
from telebot import types
import os

# Ваш токен бота
TOKEN = '8475867046:AAGdo11R6zH-3DFry01DWNeLlBrABcWAsLE'
bot = telebot.TeleBot(TOKEN)

# Чат администратора (ID группы или личного чата)
ADMIN_CHAT_ID = '528d64aa'

# Тексты и фотография
welcome_text = "Добро пожаловать в наш клан!\nЗдесь мы играем вместе и побеждаем!"
criteria_text = """
Чтобы вступить в клан, пожалуйста, расскажите немного о себе:
- Какой опыт игры имеете?
- Почему хотите присоединиться именно к нашему клану?
"""
photo_path = "welcome_photo.jpg"

# Функция отправки приветственного сообщения
def send_welcome_message(chat_id):
    with open(photo_path, 'rb') as photo_file:
        bot.send_photo(chat_id, photo_file, caption=welcome_text)

# Обработка команд
@bot.message_handler(commands=['start'])
def start(message):
    markup = types.ReplyKeyboardMarkup(row_width=1)
    button_apply = types.KeyboardButton("Подать заявку")
    button_change_settings = types.KeyboardButton("Настройки")
    markup.add(button_apply, button_change_settings)
    
    send_welcome_message(message.chat.id)
    bot.send_message(message.chat.id, criteria_text, reply_markup=markup)

# Заявка кандидата
@bot.message_handler(func=lambda message: message.text == "Подать заявку")
def apply_to_clan(message):
    # Перенаправление заявки в чат администратору
    bot.forward_message(ADMIN_CHAT_ID, message.chat.id, message.message_id)
    bot.send_message(message.chat.id, "Заявка отправлена на рассмотрение администрацией.")

# Меню управления настройками
@bot.message_handler(func=lambda message: message.text == "Настройки")
def change_settings(message):
    if message.from_user.id != ADMIN_CHAT_ID:
        return
    
    markup = types.ReplyKeyboardMarkup(row_width=1)
    button_change_welcome = types.KeyboardButton("Редактировать приветствие")
    button_change_criteria = types.KeyboardButton("Редактировать требования")
    button_change_photo = types.KeyboardButton("Загрузить новую обложку")
    markup.add(button_change_welcome, button_change_criteria, button_change_photo)
    
    bot.send_message(message.chat.id, "Выберите пункт меню для изменений:", reply_markup=markup)

# Редактирование приветствия
@bot.message_handler(func=lambda message: message.text == "Редактировать приветствие")
def change_welcome(message):
    global welcome_text
    new_welcome_text = bot.reply_to(message, "Напишите новое приветственное сообщение:")
    welcome_text = new_welcome_text.text
    bot.send_message(message.chat.id, "Приветствие успешно обновлено!")

# Изменение критериев вступлению
@bot.message_handler(func=lambda message: message.text == "Редактировать требования")
def change_criteria(message):
    global criteria_text
    new_criteria_text = bot.reply_to(message, "Введите новые требования для вступления:")
    criteria_text = new_criteria_text.text
    bot.send_message(message.chat.id, "Требования успешно обновлены!")

# Загрузка новой фотографии-приветствия
@bot.message_handler(content_types=['photo'], func=lambda message: message.caption == "Загрузить новую обложку")
def change_photo(message):
    file_info = bot.get_file(message.photo[-1].file_id)
    downloaded_file = bot.download_file(file_info.file_path)
    
    with open(photo_path, 'wb') как new_file:
        new_file.write(downloaded_file)
        
    bot.send_message(message.chat.id, "Обложка успешно обновлена!")

# Запуск бота
if __name__ == "__main__":
    bot.polling()
