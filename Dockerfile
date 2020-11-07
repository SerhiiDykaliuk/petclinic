FROM openjdk:11
COPY ./petclinic_1/target/*.jar /petclinic.jar
CMD java -jar /petclinic.jar
