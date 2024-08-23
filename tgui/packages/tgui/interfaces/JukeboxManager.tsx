import { BooleanLike } from 'common/react';
import { formatTime } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Input, Section, Table } from '../components';
import { Window } from '../layouts';

type Data = {
  songs: Song[];
};

type Song = {
  hosted: BooleanLike;
  name: string;
  length: number;
  beat: number;
  path: string;
};

export const JukeboxManager = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { songs } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  return (
    <Window width={500} height={500} theme="admin">
      <Window.Content scrollable>
        <Section fill scrollable title={'Jukebox Manager'}>
          <Table>
            <Table.Row header>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Length</Table.Cell>
              <Table.Cell>Beat</Table.Cell>
              <Table.Cell>Actions</Table.Cell>
            </Table.Row>
            {songs.map((song) => (
              <Table.Row key={song.name} className="Table__row candystripe">
                <Table.Cell>{song.name}</Table.Cell>
                <Table.Cell>{formatTime(song.length)}</Table.Cell>
                <Table.Cell>{song.beat}</Table.Cell>
                <Table.Cell>
                  <Button
                    icon="download"
                    tooltip="Save file to your computer"
                    onClick={() => act('download', { path: song.path, name: song.name })}
                  />
                  <Button
                    icon={song.hosted ? 'trash' : 'times'}
                    tooltip={song.hosted ? 'Delete file from the server' : 'Remove track from the jukebox'}
                    onClick={() => act('delete', { path: song.path, name: song.name })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
