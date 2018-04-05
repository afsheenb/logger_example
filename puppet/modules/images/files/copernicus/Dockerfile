FROM node:7.9.0-alpine

# Set a working directory
WORKDIR /usr/src/app

COPY package.json yarn.lock ./

# Install Node.js dependencies
RUN yarn install

COPY . .

RUN yarn build

# Copy application files
# COPY ./build .

EXPOSE 3000

CMD [ "node", "build/server.js" ]
