import Immutable from 'seamless-immutable';
import { testReducerSnapshotWithFixtures } from '@theforeman/test';
import {
  SELECT_ROWS,
  UNSELECT_ROWS,
  UNSELECT_ALL_ROWS,
  SELECT_ALL_ROWS,
  OPEN_SELECT_ALL,
} from '../constants/SelectionConstants';
import reducer from './selectionReducer';

const fixtures = {
  'should return the initial state': {},

  'should handle OPEN_SELECT_ALL': {
    action: {
      type: OPEN_SELECT_ALL,
    },
  },
  'should handle SELECT_ROWS': {
    action: {
      type: SELECT_ROWS,
      payload: [1, 2, 3, 4, 5, 6, 7],
    },
  },
  'should handle UNSELECT_ROWS': {
    action: {
      type: UNSELECT_ROWS,
      payload: [{ id: 4 }],
    },
  },
  'should handle UNSELECT_ALL_ROWS': {
    action: {
      type: UNSELECT_ALL_ROWS,
    },
  },
  'should handle SELECT_ALL_ROWS': {
    action: {
      type: SELECT_ALL_ROWS,
    },
  },
  'should handle UNSELECT_ROWS with all rows selected': {
    state: Immutable({ allRowsSelected: true }),
    action: {
      type: UNSELECT_ROWS,
      payload: { id: [4], results: [{ id: 3 }, { id: 4 }, { id: 5 }] },
    },
  },
};

describe('selectionReducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
