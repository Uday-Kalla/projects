const express = require('express');
const app = express();
const port = process.env.PORT || 3001;

app.use(express.json());

let appointments = [
  { id: '1', patientId: '1', date: '2023-06-15', time: '10:00', doctor: 'Dr. Smith' },
  { id: '2', patientId: '2', date: '2023-06-16', time: '14:30', doctor: 'Dr. Johnson' }
];

app.get('/health', (req, res) => res.status(200).json({ status: 'OK', service: 'Appointment Service' }));
app.get('/appointments', (req, res) => res.json({ message: 'Appointments retrieved successfully', count: appointments.length, appointments }));

app.listen(port, '0.0.0.0', () => console.log(`Appointment service listening at http://0.0.0.0:${port}`));
