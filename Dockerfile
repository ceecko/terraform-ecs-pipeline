FROM node:12-alpine

COPY --chown=node:node . .
RUN npm install --production

CMD ["npm", "start"]