import Immutable from 'seamless-immutable';
import { union } from 'lodash';
import {
  SELECT_ROWS,
  UNSELECT_ROWS,
  UNSELECT_ALL_ROWS,
  SELECT_ALL_ROWS,
  OPEN_SELECT_ALL,
} from '../constants/SelectionConstants';

const initialState = Immutable({
  selectedRows: [],
  allRowsSelected: false,
  showSelectAll: false,
});

export const selectionReducer = (state = initialState, action) => {
  const { type, payload } = action;
  switch (type) {
    case SELECT_ALL_ROWS:
      return state.set('allRowsSelected', true);
    case SELECT_ROWS:
      return state.set('selectedRows', union(payload, state.selectedRows));
    case OPEN_SELECT_ALL:
      return state.set('showSelectAll', true);
    case UNSELECT_ROWS:
      if (state.allRowsSelected) {
        // User can unselect rows if only the page rows are selected
        return state
          .set(
            'selectedRows',
            payload.results.map(row => row.id).filter(row => row !== payload.id)
          )
          .set('allRowsSelected', false)
          .set('showSelectAll', false);
      }
      return state.set(
        'selectedRows',
        state.selectedRows.filter(row => row !== payload.id)
      );
    case UNSELECT_ALL_ROWS:
      return state
        .set('selectedRows', [])
        .set('allRowsSelected', false)
        .set('showSelectAll', false);
    default:
      return state;
  }
};
export default selectionReducer;
