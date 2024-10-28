import React, { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { AlertCircle } from 'lucide-react';

const generateDummyData = () => {
  return Array.from({ length: 24 }, (_, i) => ({
    time: `${i}:00`,
    temperature: Math.random() * 10 + 20,
    humidity: Math.random() * 20 + 60,
    soilMoisture: Math.random() * 30 + 40,
    lightIntensity: Math.random() * 500 + 500,
    pH: Math.random() * 2 + 5,
    co2: Math.random() * 200 + 400,
  }));
};

const GreenhouseMonitoring = () => {
  const [data, setData] = useState(generateDummyData());
  const [isIrrigationOn, setIsIrrigationOn] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      setData(generateDummyData());
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  const toggleIrrigation = () => {
    setIsIrrigationOn(!isIrrigationOn);
  };

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Greenhouse Monitoring System</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-4">
        <Card>
          <CardHeader>
            <CardTitle>Temperature</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{data[data.length - 1].temperature.toFixed(1)}°C</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Humidity</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{data[data.length - 1].humidity.toFixed(1)}%</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Soil Moisture</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{data[data.length - 1].soilMoisture.toFixed(1)}%</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Light Intensity</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{data[data.length - 1].lightIntensity.toFixed(0)} lux</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>pH</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{data[data.length - 1].pH.toFixed(2)}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>CO2</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{data[data.length - 1].co2.toFixed(0)} ppm</p>
          </CardContent>
        </Card>
      </div>
      <div className="mb-4">
        <Button onClick={toggleIrrigation} variant={isIrrigationOn ? "destructive" : "default"}>
          {isIrrigationOn ? "Turn Off Irrigation" : "Turn On Irrigation"}
        </Button>
      </div>
      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Temperature and Humidity History</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="time" />
              <YAxis yAxisId="left" />
              <YAxis yAxisId="right" orientation="right" />
              <Tooltip />
              <Legend />
              <Line yAxisId="left" type="monotone" dataKey="temperature" stroke="#8884d8" name="Temperature (°C)" />
              <Line yAxisId="right" type="monotone" dataKey="humidity" stroke="#82ca9d" name="Humidity (%)" />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardTitle>Alerts</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center text-yellow-500">
            <AlertCircle className="mr-2" />
            <p>Soil moisture is low. Consider increasing irrigation.</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default GreenhouseMonitoring;