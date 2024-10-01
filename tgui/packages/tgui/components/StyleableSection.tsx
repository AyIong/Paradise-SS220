import { InfernoNode } from 'inferno';
import { Box } from './Box';

type Props = {
  children?: InfernoNode;
  title?: string;
  titleSubtext?: string;
  titleStyle?: string[];
  textStyle?: string[];
  contentStyle?: string[];
  style?: string[];
};

// The cost of flexibility and prettiness.
export const StyleableSection = (props: Props) => {
  const { children, style, titleStyle, textStyle, title, titleSubtext, contentStyle } = props;

  return (
    <Box style={style}>
      {/* Yes, this box (line above) is missing the "Section" class. This is very intentional, as the layout looks *ugly* with it.*/}
      <Box class="Section__title" style={titleStyle}>
        <Box class="Section__titleText" style={textStyle}>
          {title}
        </Box>
        <Box className="Section__buttons" style={{ 'top': '0.5em' }}>
          {titleSubtext}
        </Box>
      </Box>
      <Box class="Section__rest">
        <Box class="Section__content" style={contentStyle}>
          {children}
        </Box>
      </Box>
    </Box>
  );
};
