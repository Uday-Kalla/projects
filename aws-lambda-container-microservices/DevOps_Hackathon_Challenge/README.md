<h3 align="center"><strong>DevOps Hackathon Challenge : Containerized Microservices Deployment</strong></h3>

---

#### Overview
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Welcome to the DevOps Hackathon Challenge ! In this hackathon, you will demonstrate your skills in containerization, Infrastructure as Code (laC), CI/CD, and cloud deployment using AWS services. You will be working with a simple healthcare application consisting of two microservices.

---

#### Challenge Structure

This hackathon offers three deployment tracks. Each team should choose one track to focus on:
	1.	##### [Amazon EKS Deployment Track](https://github.com/Uday-Kalla/projects/tree/main/aws-lambda-container-microservices/AWS_EKS_Deployment_Track/)
	2.	##### [AWS Fargate Deployment Track](https://github.com/Uday-Kalla/projects/tree/main/aws-lambda-container-microservices/AWS_Fargate_Deployment_Track/)
	3.	##### [AWS Lambda Container Deployment Track](https://github.com/Uday-Kalla/projects/tree/main/aws-lambda-container-microservices/AWS_Lambda_Container_Deployment_Track)

#### Common Requirements

Regardless of the track you choose, you will be working with the following common elements:

##### 1.	Microservices: 
You will be provided with two Node.js microservices - a Patient Service and an Appointment Service. The code for these services can be found in the Sample Microservices Code file(This is attached at below).

##### 2.	Containerization:
You need to containerize these microservices using Docker.

##### 3.	Infrastructure as Code (Terraform):
  *	Set up a Terraform project structure supporting multiple environments (dev, staging, prod).
	*	Provision the following AWS resources:
		*	VPC with public and private subnets across two availability zones
		*	IAM roles and security groups
		*	S3 bucket for Terraform state storage
		*	DynamoDB table for state locking
		*	(Other resources specific to your chosen track)

##### 4.	Terraform State Management:
  *	Implement remote state storage using S3
	*	Set up state locking with DynamoDB
	*	Configure workspace separation for different environments

##### 5.	GitHub Actions for IaC:

  * Create workflows for:
		* Terraform fmt and validate on all PRs
		* Terraform plan on pull requests
		* Terraform apply on merges to main branch

##### 6.	CI/CD:
Implement a CI/CD pipeline using GitHub Actions for your application code.

##### 7.	Monitoring and Logging: 
Set up basic monitoring and logging using AWS CloudWatch.

**Time Allocation:** You will have 5 hours to complete this challenge. Budget your time wisely across planning, development, deployment, and documentation.

#### Evaluation Criteria
While specific criteria vary by track, you will generally be evaluated on:
	1.	Correct implementation of the chosen deployment platform
	2.	Quality and security of the IaC implementation
	3.	Effectiveness of the CI/CD pipeline
	4.	Containerization best practices
	5.	Monitoring and logging setup
	6.	Documentation quality
	7.	Overall architecture and security considerations
	8.	Proper implementation of Terraform state management and collaboration features
	
#### Getting Started
  1.	Review the common requirements and evaluation criteria.
	2.	Choose your deployment track: EKS, Fargate, or Lambda Container.
	3.	Follow the specific instructions for your chosen track.
	4.	Use the provided microservices code as a starting point for your application.

Good luck, and happy coding!


---

<h3 align="center"><strong>Sample Microservices Code</strong></h3>

This document contains the sample code for the two microservices you'll be working with during the hackathon: Patient Service and Appointment Service.

#### Patient Service (patient-service.js)

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

#### Appointment Service (appointment-service.js)
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

---
