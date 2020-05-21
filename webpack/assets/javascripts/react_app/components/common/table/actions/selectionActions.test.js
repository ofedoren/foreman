import { testActionSnapshotWithFixtures } from '@theforeman/test';
import {
  selectPage,
  selectAllRows,
  unselectAllRows,
  selectRow,
  unselectRow,
} from './selectionActions';

const fixtures = {
  'should selectPage and succeed': () => selectPage([{ id: 'some-id' }]),
  'should selectAllRows and succeed': () => selectAllRows(),
  'should unselectAllRows and succeed': () => unselectAllRows(),
  'should selectRow and succeed': () => selectRow('some-id'),
  'should unselectRow and succeed': () =>
    unselectRow('some-id', [{ id: 'some-id' }, { id: 'some-id2' }]),
};
describe('selectionActions', () => {
  testActionSnapshotWithFixtures(fixtures);
});
