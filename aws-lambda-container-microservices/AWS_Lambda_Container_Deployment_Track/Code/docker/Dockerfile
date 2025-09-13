FROM public.ecr.aws/lambda/nodejs:18

WORKDIR /var/task

COPY package*.json ./
RUN npm install --only=production

COPY appointment-service.js handler.js ./

CMD [ "handler.handler" ]
