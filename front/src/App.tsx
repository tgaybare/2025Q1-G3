import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from 'react-router-dom';
import Login from './pages/login';
import Dashboard from './pages/dashboard';
import React from 'react';
import { Amplify } from 'aws-amplify';
import { withAuthenticator } from '@aws-amplify/ui-react';

Amplify.configure({
  Auth: {
    region: 'us-east-1', // your region
    userPoolId: 'us-east-1_XXXXXXXXX',
    userPoolWebClientId: 'xxxxxxxxxxxxxxxxxxxxxxxxxx',
    authenticationFlowType: 'USER_PASSWORD_AUTH',
  },
});

function App({ signOut, user }: any) {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/" element={<Navigate to="/login" />} />
      </Routes>
    </Router>
  );
}

export default withAuthenticator(App);
