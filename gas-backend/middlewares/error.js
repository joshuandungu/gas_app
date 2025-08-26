const { createLogger, format, transports } = require('winston');
const { combine, timestamp, printf } = format;

const logFormat = printf(({ level, message, timestamp, stack }) => {
  return `${timestamp} ${level}: ${stack || message}`;
});

const logger = createLogger({
  level: 'info',
  format: combine(
    timestamp(),
    format.errors({ stack: true }),
    logFormat
  ),
  transports: [
    new transports.Console(),
    new transports.File({ filename: 'error.log', level: 'error' }),
    new transports.File({ filename: 'combined.log' }),
  ],
});

const errorHandler = (err, req, res, next) => {
  logger.error(err);
  
  res.status(err.status || 500).json({
    success: false,
    error: {
      message: err.message || 'Internal Server Error',
      status: err.status || 500,
    },
  });
};

const notFound = (req, res, next) => {
  next(createError(404, 'Not Found'));
};

module.exports = {
  errorHandler,
  notFound,
  logger,
};