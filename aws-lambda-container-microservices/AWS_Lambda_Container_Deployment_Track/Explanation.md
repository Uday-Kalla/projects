### Port Issue:

Both the **Appointment-service.js** and **Patient-service.js** calls `app.listen(...)`. 
**Lambda (even with container support)** won’t work unless you remove `app.listen`, because Lambda does not allow a server to bind to a port.
In Lambda you should not call app.listen (Lambda runs via handler). Minimal change: replace the app.listen(...) line with the guarded block below and export app so the Lambda handler (handler.js) can wrap it.
