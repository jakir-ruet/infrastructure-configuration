## Getting strated NodeJS Install & Apps Create

### Prepare Ubuntu & Install Node.js
```bash
sudo apt update && sudo apt upgrade -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
node -v
nvm current
npm -v
```

### Make a Node.js App

```bash
mkdir express-app
cd express-app
npm init -y
npm install express
node app.js
```
