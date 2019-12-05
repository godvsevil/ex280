ARG prodimage_tag
ARG oauth_path_repo
FROM $prodimage_tag
#Import the lightweight production image


#Import the build code path
ARG source_path
ARG baseBranch
ARG projectName

#Copy the code in to lightweight production environment
COPY $source_path/docroot/ /var/www/html/
COPY $source_path/$oauth_path_repo /var/www/$oauth_path
#COPY $source_path/oauth_keys /var/www/oauth_keys/
ADD docker-utils/nginx/error.html /var/www/html/
#COPY docker-utils/config/settings.php /var/www/html/sites/default/
COPY docker-utils/filebeat/filebeat-$projectName-$baseBranch.yaml /etc/filebeat/filebeat.yml
COPY docker-utils/lm_env/database-$projectName-$baseBranch.php /var/www/html/lm/config/database.php
COPY docker-utils/lm_env/database-$projectName-$baseBranch.conf /var/www/html/lm/config/database_conf.php
RUN chmod 755 /etc/filebeat/filebeat.yml
RUN chmod 755 /root/start.sh

CMD ["/root/start.sh"]
