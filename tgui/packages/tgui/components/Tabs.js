/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Component } from 'inferno';
import { canRender, classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Icon } from './Icon';

export class Tabs extends Component {
  constructor(props) {
    super(props);
    this.state = {
      preventAnimations: false,
    };
  }

  // We don't want strange border height/width animation when change tabs verticality
  componentDidUpdate(prevProps) {
    if (prevProps.vertical !== this.props.vertical) {
      this.setState({ preventAnimations: true }, () => {
        setTimeout(() => this.setState({ preventAnimations: false }), 200);
      });
    }
  }

  render() {
    const { className, vertical, fill, fluid, children, ...rest } = this.props;
    const { preventAnimations } = this.state;

    return (
      <div
        className={classes([
          'Tabs',
          vertical ? 'Tabs--vertical' : 'Tabs--horizontal',
          fill && 'Tabs--fill',
          fluid && 'Tabs--fluid',
          preventAnimations && 'Tabs--noAnim',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}
      >
        {children}
      </div>
    );
  }
}

const Tab = (props) => {
  const { className, selected, color, icon, leftSlot, rightSlot, children, ...rest } = props;
  return (
    <div
      className={classes([
        'Tab',
        'Tabs__Tab',
        'Tab--color--' + color,
        selected && 'Tab--selected',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      {(canRender(leftSlot) && <div className="Tab__left">{leftSlot}</div>) ||
        (!!icon && (
          <div className="Tab__left">
            <Icon name={icon} />
          </div>
        ))}
      <div className="Tab__text">{children}</div>
      {canRender(rightSlot) && <div className="Tab__right">{rightSlot}</div>}
    </div>
  );
};

Tabs.Tab = Tab;
