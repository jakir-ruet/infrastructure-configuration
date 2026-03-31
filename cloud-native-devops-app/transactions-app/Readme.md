```bash
mkdir transactions-app
cd transactions-app
npm init -y
npm install express mysql2 dotenv morgan
npm install --save-dev nodemon
```

```bash
transactions-app
│
├── index.js
├── .env
├── package.json
├── Dockerfile
├── docker-compose.yml
│
├── public/
│   └── index.html
│
├── schema/
│   └── backend.sql
│
└── src/
    ├── app.js
    ├── config/db.config.js
    ├── controllers/transaction.controller.js
    ├── middlewares/error.middleware.js
    ├── models/transaction.model.js
    ├── routes/transaction.routes.js
    ├── services/transaction.service.js
```

```bash
npm install
npm run dev
node index.js
```

```bash
docker-compose up --build
```

```bash
mysql -u root -p
```
