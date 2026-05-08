import React from 'react';
import { Box, MenuItem, Select, FormControl, InputLabel, Button } from '@mui/material';
import FilterListIcon from '@mui/icons-material/FilterList';

import { useUI } from '../contexts/ThemeContext';

export default function DashboardFilters() {
  const { t } = useUI();
  const [dateRange, setDateRange] = React.useState('7');
  const [plantType, setPlantType] = React.useState('all');

  return (
    <Box display="flex" gap={2} alignItems="center" flexWrap="wrap">
      <FormControl size="small" sx={{ minWidth: 150, bgcolor: 'background.paper', borderRadius: 2 }}>
        <InputLabel>{t('timeRange')}</InputLabel>
        <Select
          value={dateRange}
          label={t('timeRange')}
          onChange={(e) => setDateRange(e.target.value)}
          sx={{ borderRadius: 2 }}
        >
          <MenuItem value="7">{t('last7Days')}</MenuItem>
          <MenuItem value="30">{t('last30Days')}</MenuItem>
          <MenuItem value="90">{t('last90Days')}</MenuItem>
        </Select>
      </FormControl>

      <FormControl size="small" sx={{ minWidth: 150, bgcolor: 'background.paper', borderRadius: 2 }}>
        <InputLabel>{t('plantType')}</InputLabel>
        <Select
          value={plantType}
          label={t('plantType')}
          onChange={(e) => setPlantType(e.target.value)}
          sx={{ borderRadius: 2 }}
        >
          <MenuItem value="all">{t('allCrops')}</MenuItem>
          <MenuItem value="tomato">{t('tomato')}</MenuItem>
          <MenuItem value="potato">{t('potato')}</MenuItem>
          <MenuItem value="pepper">{t('pepper')}</MenuItem>
        </Select>
      </FormControl>

      <Button 
        variant="outlined" 
        startIcon={<FilterListIcon />}
        sx={{ borderRadius: 2, height: 40, borderColor: 'divider', color: 'text.secondary' }}
      >
        {t('moreFilters')}
      </Button>
    </Box>
  );
}
