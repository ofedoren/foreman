import {
  selectRow,
  selectPage,
  unselectAllRows,
  unselectRow,
} from '../actions/selectionActions';

export const getSelectionController = ({
  allRowsSelected,
  rows,
  selectedRows,
  dispatch,
}) => {
  const checkAllPageSelected = () =>
    allRowsSelected || rows.length === selectedRows.length;

  return {
    allRowsSelected,
    allPageSelected: () => checkAllPageSelected(),
    selectPage: () => {
      if (checkAllPageSelected()) dispatch(unselectAllRows());
      else {
        dispatch(selectPage(rows));
      }
    },
    selectRow: ({ rowData: { id } }) => {
      if (selectedRows.includes(id) || allRowsSelected)
        dispatch(unselectRow(id, allRowsSelected && rows));
      else dispatch(selectRow(id));
    },
    isSelected: ({ rowData }) =>
      allRowsSelected || selectedRows.includes(rowData.id),
  };
};
