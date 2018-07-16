# Use OpenJDK 8
FROM openjdk:8-jdk

# Set a sensible server directory.
WORKDIR /home/bdd-security

# Add the directory
ADD . .

# run gradle
RUN ./gradlew buildIt

# Execute gradle tests
CMD \
  ./gradlew -Dcucumber.options="--tags ${TAGS} --tags ${TAGS_SKIP}"
