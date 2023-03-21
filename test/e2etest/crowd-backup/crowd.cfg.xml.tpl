<?xml version="1.0" encoding="UTF-8"?>

<application-configuration>
  <setupStep>complete</setupStep>
  <setupType>install.new</setupType>
  <buildNumber>1891</buildNumber>
  <properties>
    <property name="crowd.clustering.enabled">true</property>
    <property name="crowd.server.id">BF06-4UG3-OJW2-FIQD</property>
    <property name="hibernate.c3p0.acquire_increment">1</property>
    <property name="hibernate.c3p0.idle_test_period">100</property>
    <property name="hibernate.c3p0.max_size">30</property>
    <property name="hibernate.c3p0.max_statements">0</property>
    <property name="hibernate.c3p0.min_size">0</property>
    <property name="hibernate.c3p0.timeout">30</property>
    <property name="hibernate.connection.driver_class">org.postgresql.Driver</property>
    <property name="hibernate.connection.password">{{ .crowd_rds_password }}</property>
    <property name="hibernate.connection.url">{{ .crowd_jdbc_url }}?reWriteBatchedInserts=true</property>
    <property name="hibernate.connection.username">postgres</property>
    <property name="hibernate.dialect">org.hibernate.dialect.PostgreSQLDialect</property>
    <property name="hibernate.setup">true</property>
    <property name="license">{{ .crowd_license }}</property>
  </properties>
</application-configuration>