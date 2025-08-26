// middleware/auth.js

// Middleware that allows all requests without authentication
const auth = (req, res, next) => {
  // Optional: attach a dummy user object if your code expects req.user
  req.user = {
    uid: 'guest',
    email: 'guest@example.com',
  };
  next();
};

module.exports = auth;
