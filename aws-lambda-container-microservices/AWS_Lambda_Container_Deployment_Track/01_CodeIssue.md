### Small code change required in your services
---

**Port Issue:**

* Both the **Appointment-service.js** and **Patient-service.js** calls `app.listen(...)`. 
* **Lambda (even with container support)** won’t work unless you remove `app.listen`, because Lambda does not allow a server to bind to a port.
* In Lambda you should not call app.listen (Lambda runs via handler). Minimal change: replace the app.listen(...) line with the guarded block below and export app so the Lambda handler (handler.js) can wrap it.

Change these lines at the bottom of services.

Replace:
```js
app.listen(port, '0.0.0.0', () => {
  console.log(`Appointment service listening at http://0.0.0.0:${port}`);
});
```
With (exact replacement — only these lines):
```js
// Only start a standalone HTTP server when NOT running inside Lambda
if (!process.env.AWS_LAMBDA_FUNCTION_NAME) {
  app.listen(port, '0.0.0.0', () => {
    console.log(`Appointment service listening at http://0.0.0.0:${port}`);
  });
}

module.exports = app; // export for the Lambda handler wrapper
```
This is the only change you need in the app source to support both running locally (npm start) and running inside AWS Lambda container images.

---
#### Codes After Change

**Patient-service.js**
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
    
    // Only start a standalone HTTP server when NOT running inside Lambda
    if (!process.env.AWS_LAMBDA_FUNCTION_NAME) {
    app.listen(port, '0.0.0.0', () => {
        console.log(`Appointment service listening at http://0.0.0.0:${port}`);
    });
    }

    module.exports = app; // export for the Lambda handler wrapper
```
**Appointment-service.js
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
    
    // Only start a standalone HTTP server when NOT running inside Lambda
    if (!process.env.AWS_LAMBDA_FUNCTION_NAME) {
    app.listen(port, '0.0.0.0', () => {
        console.log(`Appointment service listening at http://0.0.0.0:${port}`);
    });
    }

    module.exports = app; // export for the Lambda handler wrapper
```
