import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { formatTime } from 'common/string';

import { BooleanLike } from '../../common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Icon,
  Input,
  Knob,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  admin: BooleanLike;
  active: BooleanLike;
  looping: BooleanLike;
  saveTrack: BooleanLike;
  need_coin: BooleanLike;
  payment: BooleanLike;
  volume: number;
  startTime: number;
  worldTime: number;
  selectedName: string | null;
  selectedLength: number | null;
  songs: Song[];
};

type Song = {
  name: string;
  length: number;
  beat: number;
};

const MAX_NAME_LENGTH = 35;

export const Jukebox = (props, context) => {
  const { data } = useBackend<Data>(context);
  const [uploadTrack, setUploadTrack] = useLocalState(context, 'uploadTrack', false);
  const [trackName, setTrackName] = useLocalState(context, 'trackName', '');
  const [trackMinutes, setTrackMinutes] = useLocalState(context, 'trackMinutes', 4);
  const [trackSeconds, setTrackSeconds] = useLocalState(context, 'trackSeconds', 0);
  const [trackBeat, setTrackBeat] = useLocalState(context, 'trackBeat', 10);

  return (
    <Window title="Jukebox" width={350} height={uploadTrack ? 585 : 435}>
      {!!data.need_coin && !data.payment && !data.admin && <NoCoin />}
      <Window.Content>
        <Stack fill vertical>
          <Stack>
            <PlayerControls uploadTrack={uploadTrack} setUploadTrack={setUploadTrack} />
            <VolumeControls />
          </Stack>
          <TrackList />
          {uploadTrack && (
            <TrackUploading
              trackName={trackName}
              setTrackName={setTrackName}
              trackMinutes={trackMinutes}
              setTrackMinutes={setTrackMinutes}
              trackSeconds={trackSeconds}
              setTrackSeconds={setTrackSeconds}
              trackBeat={trackBeat}
              setTrackBeat={setTrackBeat}
            />
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PlayerControls = ({ uploadTrack, setUploadTrack }, context) => {
  const { act, data } = useBackend<Data>(context);
  const { admin, active, looping, selectedName, selectedLength, startTime, worldTime } = data;

  const trackTimer = (
    <Box textAlign="center">
      {looping
        ? '∞ / ∞'
        : `${active ? formatTime(Math.round(worldTime - startTime)) : formatTime(0)} / ${formatTime(selectedLength)}`}
    </Box>
  );

  return (
    <Stack.Item grow textAlign="center">
      <Section fill title="Music Player">
        <Stack fill vertical>
          {selectedName && (
            <Stack.Item bold maxWidth="240px">
              {selectedName.length > MAX_NAME_LENGTH ? <marquee>{selectedName}</marquee> : selectedName}
            </Stack.Item>
          )}
          <Stack fill mt={1.5}>
            <Stack.Item grow basis="0">
              <Button
                fluid
                color="transparent"
                icon={active ? 'stop' : 'play'}
                selected={active}
                onClick={() => act('toggle')}
              >
                {active ? 'Stop' : 'Play'}
              </Button>
            </Stack.Item>
            <Stack.Item grow basis="0">
              <Button
                fluid
                color="transparent"
                icon="arrows-rotate"
                selected={looping}
                disabled={active}
                onClick={() => act('loop', { looping: !looping })}
              >
                Repeat
              </Button>
            </Stack.Item>
            {!!admin && (
              <Stack.Item>
                <Button
                  color="transparent"
                  icon="download"
                  tooltip="Upload a new track"
                  checked={uploadTrack}
                  onClick={() => setUploadTrack(!uploadTrack)}
                />
              </Stack.Item>
            )}
          </Stack>
          <Stack.Item>
            <ProgressBar
              minValue={0}
              value={looping ? selectedLength : active ? Math.round(worldTime - startTime) : 0}
              maxValue={selectedLength}
            >
              {trackTimer}
            </ProgressBar>
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const VolumeControls = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { active, volume } = data;
  return (
    <Stack.Item>
      <Section fill>
        {active ? <OnMusic /> : null}
        <Stack mb={1.5}>
          <Stack.Item grow m={0}>
            <Button
              color="transparent"
              icon="fast-backward"
              onClick={() =>
                act('set_volume', {
                  volume: 'min',
                })
              }
            />
          </Stack.Item>
          <Stack.Item m={0}>
            <Button
              color="transparent"
              icon="undo"
              onClick={() =>
                act('set_volume', {
                  volume: 'reset',
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow m={0} textAlign="right">
            <Button
              color="transparent"
              icon="fast-forward"
              onClick={() =>
                act('set_volume', {
                  volume: 'max',
                })
              }
            />
          </Stack.Item>
        </Stack>
        <Stack.Item pr={1} pl={1} textAlign="center" textColor="label">
          <Knob
            size={1.75}
            value={volume}
            unit="%"
            minValue={0}
            maxValue={50}
            step={1}
            stepPixelSize={5}
            onDrag={(e, value) =>
              act('set_volume', {
                volume: value,
              })
            }
          />
          <Box mt={0.75}>Volume</Box>
        </Stack.Item>
      </Section>
    </Stack.Item>
  );
};

const TrackList = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { active, selectedName, songs } = data;

  const songs_sorted: Song[] = flow([sortBy((song: Song) => song.name)])(songs);
  const totalTracks = songs_sorted.length;
  const selectedTrackNumber = selectedName ? songs_sorted.findIndex((song) => song.name === selectedName) + 1 : 0;

  return (
    <Stack.Item grow textAlign="center">
      <Section
        fill
        scrollable
        title="Available tracks"
        buttons={
          <Button
            bold
            icon="random"
            color="transparent"
            tooltip="Choose a random track"
            tooltipPosition="top-end"
            onClick={() => {
              const randomIndex = Math.floor(Math.random() * totalTracks);
              const randomTrack = songs_sorted[randomIndex];
              act('select_track', { track: randomTrack.name });
            }}
          >
            {selectedTrackNumber}/{totalTracks}
          </Button>
        }
      >
        {songs_sorted.map((song) => {
          return (
            <Stack.Item key={song.name} mb={0.5} textAlign="left">
              <Button
                fluid
                color="transparent"
                tooltip={song.name.length > MAX_NAME_LENGTH ? song.name : null}
                tooltipPosition="bottom"
                selected={selectedName === song.name}
                disabled={active}
                onClick={() => {
                  act('select_track', { track: song.name });
                }}
              >
                <Stack fill>
                  <Stack.Item grow overflow="hidden" style={{ textOverflow: 'ellipsis' }}>
                    {song.name}
                  </Stack.Item>
                  <Stack.Item>{formatTime(song.length)}</Stack.Item>
                </Stack>
              </Button>
            </Stack.Item>
          );
        })}
      </Section>
    </Stack.Item>
  );
};

const TrackUploading = (
  { trackName, trackMinutes, trackSeconds, trackBeat, setTrackName, setTrackMinutes, setTrackSeconds, setTrackBeat },
  context
) => {
  const { act, data } = useBackend<Data>(context);

  return (
    <Stack.Item>
      <Section fill title="Upload track">
        <Stack fill vertical textAlign="center">
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Name">
                <Input
                  width="100%"
                  placeholder="Track name..."
                  value={trackName}
                  onChange={(e, value) => setTrackName(value)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Length">
                <Stack>
                  <Stack.Item grow>
                    <NumberInput
                      width="100%"
                      step={1}
                      unit="min"
                      minValue={0}
                      value={trackMinutes}
                      maxValue={10}
                      stepPixelSize={5}
                      onChange={(e, value) => setTrackMinutes(value)}
                    />
                  </Stack.Item>
                  <Stack.Item textAlign="center">:</Stack.Item>
                  <Stack.Item grow>
                    <NumberInput
                      width="100%"
                      step={1}
                      unit="sec"
                      minValue={1}
                      value={trackSeconds}
                      maxValue={59}
                      stepPixelSize={3}
                      onChange={(e, value) => setTrackSeconds(value)}
                    />
                  </Stack.Item>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="BPS">
                <NumberInput
                  width="100%"
                  step={1}
                  minValue={0}
                  value={trackBeat}
                  maxValue={100}
                  onChange={(e, value) => setTrackBeat(value)}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="upload"
                  disabled={!trackName || !(trackMinutes || trackSeconds) || !trackBeat}
                  onClick={() => {
                    act('add_song', {
                      track_name: trackName,
                      track_length: trackMinutes * 600 + trackSeconds * 10,
                      track_beat: trackBeat,
                    });
                    setTrackName('');
                  }}
                >
                  Upload New Track
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="floppy-disk"
                  selected={data.saveTrack}
                  tooltip="Save the uploaded track on the server"
                  onClick={() => act('save_song')}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const OnMusic = () => (
  <Dimmer textAlign="center">
    <Icon name="music" size={3} color="gray" mb={1} />
    <Box color="label" bold>
      Music is playing
    </Box>
  </Dimmer>
);

const NoCoin = () => (
  <Dimmer textAlign="center">
    <Icon name="coins" size={6} color="gold" mr={1} />
    <Box color="label" bold mt={5} fontSize={2}>
      Insert a coin
    </Box>
  </Dimmer>
);
