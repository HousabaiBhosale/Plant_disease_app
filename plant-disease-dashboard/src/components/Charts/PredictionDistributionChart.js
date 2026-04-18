import React from 'react';
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Card, CardContent, CardHeader } from '@mui/material';

const COLORS = ['#1a237e', '#ff9800', '#4caf50', '#f44336'];

export default function PredictionDistributionChart({ localCount, cloudCount }) {
  const data = [
    { name: 'Local (TFLite)', value: localCount, color: '#1a237e' },
    { name: 'Cloud (API)', value: cloudCount, color: '#ff9800' },
  ];

  return (
    <Card>
      <CardHeader
        title="Prediction Distribution"
        subheader="Local vs Cloud inference"
      />
      <CardContent>
        <ResponsiveContainer width="100%" height={300}>
          <PieChart>
            <Pie
              data={data}
              cx="50%"
              cy="50%"
              labelLine={false}
              label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
              outerRadius={80}
              fill="#8884d8"
              dataKey="value"
            >
              {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
