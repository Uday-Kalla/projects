<h3 align="center"><strong>AWS Fargate Deployment Track</strong></h3>

---

#### Objective
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Deploy the containerized microservices using AWS Fargate, demonstrating your skills in container orchestration, serverless computing, and AWS services.

---

#### Technical Requirements

##### 1.	Infrastructure as Code (Terraform)
  * Provision a VPC with public and private subnets
	* Set up an ECS cluster with Fargate launch type
	* Configure necessary IAM roles and security groups\
	* Set up an ECR repository for your container images
	* Create an Application Load Balancer

##### 2.	Containerization
  * Create a Dockerfile for the microservices
	* Build and push the Docker image to ECR

##### 3.	ECS/Fargate
  * Create ECS task definitions
	* Set up ECS services for your applications

##### 4.	CI/CD (GitHub Actions)
  * Implement a workflow for Terraform (lint, plan, apply)
	* Create a workflow for building and pushing Docker images
	* Implement a workflow for deploying to ECS/Fargate

##### 5.	Monitoring and Logging
  * Set up CloudWatch for container insights and application logging
	* (Bonus) Implement custom CloudWatch dashboards

#### Deliverables

##### 1.	GitHub repository containing:
  * Terraform code
	* Dockerfiles
	* ECS task definitions
	* GitHub Actions workflows
	* Application code (provided microservices)

##### 2.	Documentation:
  * Architecture diagram
	* Setup and deployment instructions
	* Monitoring and logging overview

#### Evaluation Criteria
  1.	Fargate cluster configuration and security
	2.	ECS task and service management
	3.	CI/CD pipeline efficiency and reliability
	4.	IaC quality and modularity
	5.	Containerization best practices
	6.	Monitoring and logging effectiveness
	7.	Documentation clarity and completeness

---

<h3 align="center"><strong>microservices Code</strong></h3>

#### Appointment-service.js
```js
const express = require('express');
    const app = express();
    const port = process.env.PORT || 3001;
    
    app.use(express.json());
    
    // In-memory data store (replace with a database in a real application)
    let appointments = [
      { id: '1', patientId: '1', date: '2023-06-15', time: '10:00', doctor: 'Dr. Smith' },
      { id: '2', patientId: '2', date: '2023-06-16', time: '14:30', doctor: 'Dr. Johnson' }
    ];
    
    app.get('/health', (req, res) => {
      res.status(200).json({ status: 'OK', service: 'Appointment Service' });
    });
    
    app.get('/appointments', (req, res) => {
      res.json({ 
        message: 'Appointments retrieved successfully',
        count: appointments.length,
        appointments: appointments 
      });
    });
    
    app.get('/appointments/:id', (req, res) => {
      const appointment = appointments.find(a => a.id === req.params.id);
      if (appointment) {
        res.json({ 
          message: 'Appointment found',
          appointment: appointment 
        });
      } else {
        res.status(404).json({ error: 'Appointment not found' });
      }
    });
    
    app.post('/appointments', (req, res) => {
      try {
        const { patientId, date, time, doctor } = req.body;
        if (!patientId || !date || !time || !doctor) {
          return res.status(400).json({ error: 'Patient ID, date, time, and doctor are required' });
        }
        const newAppointment = {
          id: (appointments.length + 1).toString(),
          patientId,
          date,
          time,
          doctor
        };
        appointments.push(newAppointment);
        res.status(201).json({ 
          message: 'Appointment scheduled successfully',
          appointment: newAppointment 
        });
      } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
      }
    });
    
    app.get('/appointments/patient/:patientId', (req, res) => {
      try {
        const patientId = req.params.patientId;
        const patientAppointments = appointments.filter(appt => appt.patientId === patientId);
        if (patientAppointments.length > 0) {
          res.json({
            message: `Found ${patientAppointments.length} appointment(s) for patient ${patientId}`,
            appointments: patientAppointments
          });
        } else {
          res.status(404).json({ message: `No appointments found for patient ${patientId}` });
        }
      } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
      }
    });
    
    app.listen(port, '0.0.0.0', () => {
      console.log(`Appointment service listening at http://0.0.0.0:${port}`);
    });
```

#### Patient-service.js

```js
const express = require('express');
    const app = express();
    const port = process.env.PORT || 3000;
    
    app.use(express.json());
    
    // In-memory data store (replace with a database in a real application)
    let patients = [
      { id: '1', name: 'John Doe', age: 30, condition: 'Healthy' },
      { id: '2', name: 'Jane Smith', age: 45, condition: 'Hypertension' }
    ];
    
    app.get('/health', (req, res) => {
      res.status(200).json({ status: 'OK', service: 'Patient Service' });
    });
    
    app.get('/patients', (req, res) => {
      res.json({ 
        message: 'Patients retrieved successfully',
        count: patients.length,
        patients: patients 
      });
    });
    
    app.get('/patients/:id', (req, res) => {
      const patient = patients.find(p => p.id === req.params.id);
      if (patient) {
        res.json({ 
          message: 'Patient found',
          patient: patient 
        });
      } else {
        res.status(404).json({ error: 'Patient not found' });
      }
    });
    
    app.post('/patients', (req, res) => {
      try {
        const { name, age, condition } = req.body;
        if (!name || !age) {
          return res.status(400).json({ error: 'Name and age are required' });
        }
        const newPatient = {
          id: (patients.length + 1).toString(),
          name,
          age,
          condition: condition || 'Not specified'
        };
        patients.push(newPatient);
        res.status(201).json({ 
          message: 'Patient added successfully',
          patient: newPatient 
        });
      } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
      }
    });
    
    app.listen(port, '0.0.0.0', () => {
      console.log(`Patient service listening at http://0.0.0.0:${port}`);
    });
```

---
<h3 align="center"><strong>process of Deployment</strong></h3>
