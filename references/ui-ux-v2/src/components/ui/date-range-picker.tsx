import React from 'react';
import { Button } from './button';
import { Calendar } from 'lucide-react';

export function DatePickerWithRange({ className = "" }) {
  return (
    <Button variant="outline" className={className}>
      <Calendar className="h-4 w-4 mr-2" />
      Pick a date range
    </Button>
  );
}