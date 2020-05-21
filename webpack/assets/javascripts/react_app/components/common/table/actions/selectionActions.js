import {
  SELECT_ROWS,
  SELECT_ALL_ROWS,
  UNSELECT_ALL_ROWS,
  UNSELECT_ROWS,
  OPEN_SELECT_ALL,
} from '../constants/SelectionConstants';

export const selectPage = results => dispatch => {
  dispatch({
    type: SELECT_ROWS,
    payload: results.map(row => row.id),
  });
  dispatch({
    type: OPEN_SELECT_ALL,
  });
};

export const selectAllRows = () => ({
  type: SELECT_ALL_ROWS,
});

export const unselectAllRows = () => ({
  type: UNSELECT_ALL_ROWS,
});

export const selectRow = id => ({
  type: SELECT_ROWS,
  payload: [id],
});

export const unselectRow = (id, results) => ({
  type: UNSELECT_ROWS,
  payload: { id, results },
});
