
import * as echarts from 'echarts/core';

import { BarChart,PieChart,LineChart,GaugeChart} from 'echarts/charts';
// Import title, tooltip, cartesian grid, dataset, and built-in transform components
import {
    TooltipComponent,
    GridComponent,
} from 'echarts/components';
// Label layout and global transition features
// Import Canvas renderer; CanvasRenderer or SVGRenderer is required
import { CanvasRenderer } from 'echarts/renderers';
import { LegendComponent } from 'echarts/components';
// Register required components
echarts.use([
    GaugeChart,
    LegendComponent,
    PieChart,
    TooltipComponent,
    GridComponent,
    BarChart,
    LineChart,
    CanvasRenderer
]);

export default echarts