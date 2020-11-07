FROM openjdk:11
COPY ./target/*.jar /petclinic.jar
CMD java -jar /petclinic.jar
