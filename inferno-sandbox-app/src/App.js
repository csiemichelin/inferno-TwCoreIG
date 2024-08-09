import React, { useState, useEffect } from 'react';
import axios from 'axios';


function App() {
  const [data, setData] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios.get('https://localhost:10000/list')
      .then(response => {
        console.log('Response:', response);
        setData(response.data);
      })
      .catch(error => {
        console.error('Error fetching data:', error);
        setError(error);
      });
  }, []);

  if (error) {
    return <div>Error: {error.message}</div>;
  }

  return (
    <div>
      <h1>Validation Results</h1>
      <ul>
        {data.map((entry, index) => (
          <li key={index}>{JSON.stringify(entry)}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;