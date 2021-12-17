FROM node:12-alpine

ARG API_PORT

COPY ["package.json", "yarn.lock", "./"]

RUN yarn

COPY . .

EXPOSE ${API_PORT}

CMD [ "node", "app.js" ]
