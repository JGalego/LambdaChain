FROM public.ecr.aws/lambda/nodejs:20

COPY index.mjs package.json ./
RUN npm install --force

CMD [ "index.handler" ]
