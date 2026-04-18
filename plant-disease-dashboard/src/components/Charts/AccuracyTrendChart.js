import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { Card, CardContent, CardHeader, Typography } from '@mui/material'; // Typography imported implicitly

export default function AccuracyTrendChart({ data }) {
  if (!data || data.length === 0) {
    return (
      <Card>
        <CardContent>
          <Typography align="center" color="textSecondary">
            No data available
          </Typography>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader
        title="Model Accuracy Over Time"
        subheader="Daily accuracy tracking"
      />
      <CardContent>
        <ResponsiveContainer width="100%" height={400}>
          <LineChart
            data={data}
            margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
          >
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis domain={[0, 100]} />
            <Tooltip />
            <Legend />
            <Line
              type="monotone"
              dataKey="accuracy"
              stroke="#1a237e"
              strokeWidth={2}
              name="Accuracy (%)"
              dot={{ r: 4 }}
              activeDot={{ r: 8 }}
            />
            <Line
              type="monotone"
              dataKey="targetAccuracy"
              stroke="#ff9800"
              strokeDasharray="5 5"
              name="Target (90%)"
            />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
