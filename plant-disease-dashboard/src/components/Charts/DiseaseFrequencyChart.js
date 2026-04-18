import React from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Cell,
} from 'recharts';
import { Card, CardContent, CardHeader, Typography } from '@mui/material'; // Removed unused Box

const COLORS = ['#1a237e', '#283593', '#303f9f', '#3949ab', '#3f51b5', '#5c6bc0'];

export default function DiseaseFrequencyChart({ data }) {
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
        title="Disease Frequency Analysis"
        subheader="Top 10 most detected diseases"
      />
      <CardContent>
        <ResponsiveContainer width="100%" height={400}>
          <BarChart
            data={data}
            layout="vertical"
            margin={{ top: 5, right: 30, left: 100, bottom: 5 }}
          >
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis type="number" />
            <YAxis type="category" dataKey="disease" width={100} />
            <Tooltip />
            <Legend />
            <Bar dataKey="count" fill="#1a237e" name="Detections">
              {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
