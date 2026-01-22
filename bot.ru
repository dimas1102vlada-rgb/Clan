import logging
from telegram import Update
from telegram.ext import (
    ApplicationBuilder,
    ContextTypes,
    CommandHandler,
    MessageHandler,
    filters
)

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Ваш токен бота (полученный ранее от BotFather)
TOKEN = '8475867046:AAG56wRe-Yy4j1l38EmJKdJtSKoUtcKIJ1U'

# Функция обработки команд
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    logger.info(f'Пользователь {user.full_name} начал разговор')
    await update.message.reply_text('Привет! Я твой бот. Напиши что-нибудь.')

# Ответ на любое сообщение пользователя
async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    message = update.message.text
    reply = f"Ты сказал: '{message}'. Я понял."
    await update.message.reply_text(reply)

def main() -> None:
    app = ApplicationBuilder().token(TOKEN).build()

    # Добавляем обработчики команд
    app.add_handler(CommandHandler("start", start))

    # Реакция на любые сообщения
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))

    # Начинаем прием запросов
    app.run_polling()

if __name__ == "__main__":
    main()
