import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Input, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  name: string;
  interactions: Interaction[];
};

type Interaction = {
  name: string;
  fa_icon: string;
  key: string;
  path: string;
};

export const Interactions = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { name, interactions } = data;

  return (
    <Window title={name} width={300} height={400}>
      <Window.Content scrollable>
        <Section fill scrollable title={'Взаимодействия'}>
          {interactions.map((interaction) => (
            <Button
              key={interaction.key}
              fluid
              icon={interaction.fa_icon}
              onClick={() => act('interact', { key: interaction.key })}
            >
              {interaction.name}
            </Button>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
