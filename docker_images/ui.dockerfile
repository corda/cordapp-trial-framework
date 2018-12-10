FROM teracy/angular-cli

# Create app directory
WORKDIR /tmp/leiaui

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source

COPY . .

EXPOSE 8080
EXPOSE 4200
#RUN ng serve --host 0.0.0.0 --disable-host-check

VOLUME /tmp/leiaui

#RUN ng serve --host 0.0.0.0 --disable-host-check
ENTRYPOINT ["ng", "serve", "--host", "0.0.0.0"]

