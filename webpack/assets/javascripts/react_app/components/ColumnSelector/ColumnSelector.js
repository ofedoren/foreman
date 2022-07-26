import React, { useState, useEffect, useCallback } from 'react';
import { PropTypes } from 'prop-types';
import { Button, Modal, ModalVariant, TreeView } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import API from '../../API';
import { changeQuery } from '../../common/urlHelpers';

const ColumnSelector = props => {
  const {
    data: { url, controller, columns, initialColumns, hasPreference },
  } = props;

  const [isModalOpen, setModalOpen] = useState(false);
  const [selectedColumns, setSelectedColumns] = useState(columns);
  const [tablePreference, setTablePreference] = useState(hasPreference);

  useEffect(() => {
    if (!tablePreference) {
      createTablePreference();
      setTablePreference(true);
    }

    function createTablePreference() {
      API.post(url, { name: 'hosts', columns: getColumnKeys() });
    }
  }, [url, tablePreference, selectedColumns, getColumnKeys, initialColumns]);

  const getColumnKeys = useCallback(() => {
    const keys = selectedColumns
      .map(category => category.children)
      .flat()
      .map(column => {
        if (column.checkProps.checked) {
          return column.key;
        }
        return null;
      })
      .filter(item => item);
    return keys;
  }, [selectedColumns]);

  const updateTablePreference = useCallback(() => {
    API.put([url, controller].join('/'), { columns: getColumnKeys() });
  }, [url, controller, getColumnKeys]);

  const filterItems = useCallback((item, checkedItem) => {
    if (item.key === checkedItem.key) {
      return true;
    }

    if (item.children) {
      item.children = item.children
        .map(opt => Object.assign({}, opt))
        .filter(column => filterItems(column, checkedItem));
      return item.children;
    }

    return null;
  }, []);

  const flattenTree = useCallback(tree => {
    let result = [];
    tree.forEach(item => {
      result.push(item);
      if (item.children) {
        result = result.concat(flattenTree(item.children));
      }
    });
    return result;
  }, []);

  const onClose = () => {
    setModalOpen(!isModalOpen);
  };

  const onCancel = () => {
    setSelectedColumns(initialColumns);
    setModalOpen(!isModalOpen);
  };

  const isDisabled = () => {
    const hasPartialCheck = selectedColumns.map(
      item => item.checkProps.checked
    );
    return hasPartialCheck.every(el => el === false);
  };

  const updateCheckBox = (treeViewItem, checked = true) => {
    treeViewItem.checkProps.checked = checked;
    if (treeViewItem.children) {
      treeViewItem.children.forEach(item => {
        item.checkProps.checked = checked;
      });
    }
  };

  const onCheck = (evt, treeViewItem) => {
    const { checked } = evt.target;
    const checkedItemTree = selectedColumns
      .map(column => Object.assign({}, column))
      .filter(item => filterItems(item, treeViewItem));
    const flatCheckedItems = flattenTree(checkedItemTree);

    if (checked) {
      updateCheckBox(treeViewItem);
      setSelectedColumns(
        selectedColumns
          .concat(
            flatCheckedItems.filter(
              item => !selectedColumns.some(i => i.key === item.key)
            )
          )
          .filter(item => item.children)
      );
    } else {
      updateCheckBox(treeViewItem, false);
      setSelectedColumns(
        selectedColumns.filter(item =>
          flatCheckedItems.some(i => i.key === item.key)
        )
      );
    }
    selectedColumns.map(category => areDescendantsChecked(category));
  };

  const isChecked = dataItem => dataItem.checkProps.checked;
  const areDescendantsChecked = dataItem => {
    if (dataItem.children) {
      if (dataItem.children.every(child => isChecked(child))) {
        dataItem.checkProps.checked = true;
      } else if (dataItem.children.some(child => isChecked(child))) {
        dataItem.checkProps.checked = null;
      } else {
        dataItem.checkProps.checked = false;
      }
    }
  };

  return (
    <div className="pf-c-select-input">
      <div className="pf-c-input-group" id="column-selector">
        <Button
          id="btn-filter"
          variant="secondary"
          className="pull-left"
          onClick={() => onClose()}
        >
          {__('Manage columns')}
        </Button>
        <Modal
          variant={ModalVariant.small}
          title={__('Manage columns')}
          isOpen={isModalOpen}
          onClose={onClose}
          description={__('Select columns to display in the table')}
          position="top"
          actions={[
            <Button
              key="save"
              variant="primary"
              isDisabled={isDisabled()}
              onClick={() => {
                updateTablePreference();
                changeQuery({});
              }}
            >
              {__('Save')}
            </Button>,
            <Button key="cancel" variant="secondary" onClick={onCancel}>
              {__('Cancel')}
            </Button>,
          ]}
        >
          <TreeView data={selectedColumns} onCheck={onCheck} hasChecks />
        </Modal>
      </div>
    </div>
  );
};

ColumnSelector.propTypes = {
  data: PropTypes.shape({
    url: PropTypes.string,
    controller: PropTypes.string,
    columns: PropTypes.arrayOf(PropTypes.object),
    initialColumns: PropTypes.arrayOf(PropTypes.object),
    hasPreference: PropTypes.bool,
  }),
};

ColumnSelector.defaultProps = {
  data: {
    url: '',
    controller: '',
    columns: [],
    initialColumns: [],
    hasPreference: false,
  },
};

export default ColumnSelector;
