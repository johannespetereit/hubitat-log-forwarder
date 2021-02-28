FROM arm32v7/node:15.10.0-alpine3.10 AS builder
WORKDIR /root/build
COPY package.json .

RUN npm set progress=false && npm config set depth 0
RUN npm install --only=production 
RUN cp -R node_modules prod_node_modules
# install ALL node_modules, including 'devDependencies'
RUN npm install



#
# ---- Release ----
FROM arm32v7/node:15.10.0-alpine3.10 AS release
# copy production node_modules
COPY --from=builder /root/build/prod_node_modules ./node_modules
# copy app sources
COPY . .

ENTRYPOINT ["node", "logger.js"]