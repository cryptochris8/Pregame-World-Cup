import React from 'react';

const TestBilling: React.FC = () => {
  // Add console logging for debugging
  console.log('TestBilling component rendering');
  console.log('User agent:', navigator.userAgent);
  console.log('Current location:', window.location.href);

  return (
    <div style={{ 
      minHeight: '100vh', 
      padding: '20px', 
      backgroundColor: 'white',
      color: 'black',
      border: '2px solid red' // Make it obvious if it's rendering
    }}>
      <h1 style={{ color: 'red', fontSize: '48px' }}>TEST BILLING PAGE</h1>
      <p style={{ fontSize: '24px' }}>If you can see this, the routing is working and the component is rendering.</p>
      <p style={{ fontSize: '18px' }}>The issue was likely with the original component imports or CSS conflicts.</p>
      <div style={{ marginTop: '20px', padding: '10px', backgroundColor: 'lightgray' }}>
        <p><strong>Browser:</strong> {navigator.userAgent}</p>
        <p><strong>URL:</strong> {window.location.href}</p>
        <p><strong>Timestamp:</strong> {new Date().toISOString()}</p>
      </div>
    </div>
  );
};

export default TestBilling; 