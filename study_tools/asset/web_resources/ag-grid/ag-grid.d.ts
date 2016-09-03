// Type definitions for ag-grid v3.2.2
// Project: http://www.ag-grid.com/
// Definitions by: Niall Crosby <https://github.com/ceolter/>
// Definitions: https://github.com/borisyankov/DefinitelyTyped
declare module ag.grid {
    class ColumnChangeEvent {
        private type;
        private column;
        private columns;
        private columnGroup;
        private fromIndex;
        private toIndex;
        private finished;
        private visible;
        private pinned;
        constructor(type: string);
        toString(): string;
        withPinned(pinned: string): ColumnChangeEvent;
        withVisible(visible: boolean): ColumnChangeEvent;
        isVisible(): boolean;
        getPinned(): string;
        withColumn(column: Column): ColumnChangeEvent;
        withColumns(columns: Column[]): ColumnChangeEvent;
        withFinished(finished: boolean): ColumnChangeEvent;
        withColumnGroup(columnGroup: ColumnGroup): ColumnChangeEvent;
        withFromIndex(fromIndex: number): ColumnChangeEvent;
        withToIndex(toIndex: number): ColumnChangeEvent;
        getFromIndex(): number;
        getToIndex(): number;
        getType(): string;
        getColumn(): Column;
        getColumns(): Column[];
        getColumnGroup(): ColumnGroup;
        isRowGroupChanged(): boolean;
        isValueChanged(): boolean;
        isIndividualColumnResized(): boolean;
        isFinished(): boolean;
    }
}
declare module ag.grid {
    class Constants {
        static STEP_EVERYTHING: number;
        static STEP_FILTER: number;
        static STEP_SORT: number;
        static STEP_MAP: number;
        static ROW_BUFFER_SIZE: number;
        static MIN_COL_WIDTH: number;
        static KEY_TAB: number;
        static KEY_ENTER: number;
        static KEY_BACKSPACE: number;
        static KEY_DELETE: number;
        static KEY_ESCAPE: number;
        static KEY_SPACE: number;
        static KEY_DOWN: number;
        static KEY_UP: number;
        static KEY_LEFT: number;
        static KEY_RIGHT: number;
    }
}
declare module ag.grid {
    interface CsvExportParams {
        skipHeader?: boolean;
        skipFooters?: boolean;
        skipGroups?: boolean;
        fileName?: string;
        customHeader?: string;
        customFooter?: string;
        allColumns?: boolean;
        columnSeparator?: string;
    }
    class CsvCreator {
        private rowController;
        private columnController;
        private grid;
        private valueService;
        constructor(rowController: InMemoryRowController, columnController: ColumnController, grid: Grid, valueService: ValueService);
        exportDataAsCsv(params?: CsvExportParams): void;
        getDataAsCsv(params?: CsvExportParams): string;
        private createValueForGroupNode(node);
        private escape(value);
    }
}
declare module ag.grid {
    class Events {
        /** A new set of columns has been entered, everything has potentially changed. */
        static EVENT_COLUMN_EVERYTHING_CHANGED: string;
        /** A row group column was added, removed or order changed. */
        static EVENT_COLUMN_ROW_GROUP_CHANGE: string;
        /** A value column was added, removed or agg function was changed. */
        static EVENT_COLUMN_VALUE_CHANGE: string;
        /** A column was moved */
        static EVENT_COLUMN_MOVED: string;
        /** One or more columns was shown / hidden */
        static EVENT_COLUMN_VISIBLE: string;
        /** One or more columns was pinned / unpinned*/
        static EVENT_COLUMN_PINNED: string;
        /** A column group was opened / closed */
        static EVENT_COLUMN_GROUP_OPENED: string;
        /** A column group was opened / closed */
        static EVENT_ROW_GROUP_OPENED: string;
        /** One or more columns was resized. If just one, the column in the event is set. */
        static EVENT_COLUMN_RESIZED: string;
        static EVENT_MODEL_UPDATED: string;
        static EVENT_CELL_CLICKED: string;
        static EVENT_CELL_DOUBLE_CLICKED: string;
        static EVENT_CELL_CONTEXT_MENU: string;
        static EVENT_CELL_VALUE_CHANGED: string;
        static EVENT_CELL_FOCUSED: string;
        static EVENT_ROW_SELECTED: string;
        static EVENT_ROW_DESELECTED: string;
        static EVENT_SELECTION_CHANGED: string;
        static EVENT_BEFORE_FILTER_CHANGED: string;
        static EVENT_AFTER_FILTER_CHANGED: string;
        static EVENT_FILTER_MODIFIED: string;
        static EVENT_BEFORE_SORT_CHANGED: string;
        static EVENT_AFTER_SORT_CHANGED: string;
        static EVENT_VIRTUAL_ROW_REMOVED: string;
        static EVENT_ROW_CLICKED: string;
        static EVENT_ROW_DOUBLE_CLICKED: string;
        static EVENT_READY: string;
        static EVENT_GRID_SIZE_CHANGED: string;
    }
}
declare module ag.grid {
    class Utils {
        private static isSafari;
        private static isIE;
        static iterateObject(object: any, callback: (key: string, value: any) => void): void;
        static cloneObject(object: any): any;
        static map<TItem, TResult>(array: TItem[], callback: (item: TItem) => TResult): TResult[];
        static forEach<T>(array: T[], callback: (item: T, index: number) => void): void;
        static filter<T>(array: T[], callback: (item: T) => boolean): T[];
        static assign(object: any, source: any): void;
        static getFunctionParameters(func: any): any;
        static find(collection: any, predicate: any, value: any): any;
        static toStrings<T>(array: T[]): string[];
        static iterateArray<T>(array: T[], callback: (item: T, index: number) => void): void;
        static isNode(o: any): boolean;
        static isElement(o: any): boolean;
        static isNodeOrElement(o: any): boolean;
        static addChangeListener(element: HTMLElement, listener: EventListener): void;
        static makeNull(value: any): any;
        static removeAllChildren(node: HTMLElement): void;
        static removeElement(parent: HTMLElement, cssSelector: string): void;
        static removeFromParent(node: Element): void;
        static isVisible(element: HTMLElement): boolean;
        /**
         * loads the template and returns it as an element. makes up for no simple way in
         * the dom api to load html directly, eg we cannot do this: document.createElement(template)
         */
        static loadTemplate(template: string): Node;
        static querySelectorAll_addCssClass(eParent: any, selector: string, cssClass: string): void;
        static querySelectorAll_removeCssClass(eParent: any, selector: string, cssClass: string): void;
        static querySelectorAll_replaceCssClass(eParent: any, selector: string, cssClassToRemove: string, cssClassToAdd: string): void;
        static addOrRemoveCssClass(element: HTMLElement, className: string, addOrRemove: boolean): void;
        static addCssClass(element: HTMLElement, className: string): void;
        static offsetHeight(element: HTMLElement): number;
        static offsetWidth(element: HTMLElement): number;
        static removeCssClass(element: HTMLElement, className: string): void;
        static removeFromArray<T>(array: T[], object: T): void;
        static defaultComparator(valueA: any, valueB: any): number;
        static formatWidth(width: number | string): string;
        /**
         * Tries to use the provided renderer.
         */
        static useRenderer<TParams>(eParent: Element, eRenderer: (params: TParams) => Node | string, params: TParams): void;
        /**
         * If icon provided, use this (either a string, or a function callback).
         * if not, then use the second parameter, which is the svgFactory function
         */
        static createIcon(iconName: string, gridOptionsWrapper: GridOptionsWrapper, column: Column, svgFactoryFunc: () => Node): HTMLSpanElement;
        static createIconNoSpan(iconName: string, gridOptionsWrapper: GridOptionsWrapper, colDefWrapper: Column, svgFactoryFunc: () => Node): any;
        static addStylesToElement(eElement: any, styles: any): void;
        static getScrollbarWidth(): number;
        static isKeyPressed(event: KeyboardEvent, keyToCheck: number): boolean;
        static setVisible(element: HTMLElement, visible: boolean): void;
        static isBrowserIE(): boolean;
        static isBrowserSafari(): boolean;
    }
}
declare module ag.grid {
    class EventService {
        private allListeners;
        private globalListeners;
        private logger;
        init(loggerFactory: LoggerFactory): void;
        private getListenerList(eventType);
        addEventListener(eventType: string, listener: Function): void;
        addGlobalListener(listener: Function): void;
        removeEventListener(eventType: string, listener: Function): void;
        removeGlobalListener(listener: Function): void;
        dispatchEvent(eventType: string, event?: any): void;
    }
}
declare module ag.grid {
    class ExpressionService {
        private expressionToFunctionCache;
        private logger;
        init(loggerFactory: LoggerFactory): void;
        evaluate(expression: string, params: any): any;
        private createExpressionFunction(expression);
        private createFunctionBody(expression);
    }
}
declare module ag.grid {
    interface RowNode {
        /** Unique ID for the node. Can be though of as the index of the row in the original list,
         * however exceptions apply so don't depend on uniqueness. */
        id?: number;
        /** The user provided data */
        data?: any;
        /** The parent node to this node, or empty if top level */
        parent?: RowNode;
        /** How many levels this node is from the top */
        level?: number;
        /** True if this node is a group node (ie has children) */
        group?: boolean;
        /** True if this is the first child in this group */
        firstChild?: boolean;
        /** True if this is the last child in this group */
        lastChild?: boolean;
        /** The index of this node in the group */
        childIndex?: number;
        /** True if this row is a floating row */
        floating?: boolean;
        /** True if this row is a floating top row */
        floatingTop?: boolean;
        /** True if this row is a floating bottom row */
        floatingBottom?: boolean;
        /** If using quick filter, stores a string representation of the row for searching against */
        quickFilterAggregateText?: string;
        /** Groups only - True if row is a footer. Footers  have group = true and footer = true */
        footer?: boolean;
        /** Groups only - Children of this group */
        children?: RowNode[];
        /** Groups only - The field we are grouping on eg Country*/
        field?: string;
        /** Groups only - The key for the group eg Ireland, UK, USA */
        key?: any;
        /** Groups only - Filtered children of this group */
        childrenAfterFilter?: RowNode[];
        /** Groups only - Sorted children of this group */
        childrenAfterSort?: RowNode[];
        /** Groups only - Number of children and grand children */
        allChildrenCount?: number;
        /** Groups only - True if group is expanded, otherwise false */
        expanded?: boolean;
        /** Groups only - If doing footers, reference to the footer node for this group */
        sibling?: RowNode;
        /** Not to be used, internal temporary map used by the grid when creating groups */
        _childrenMap?: {};
        /** The height, in pixels, of this row */
        rowHeight?: number;
        /** The top pixel for this row */
        rowTop?: number;
    }
}
declare module ag.grid {
    class FloatingRowModel {
        private gridOptionsWrapper;
        private floatingTopRows;
        private floatingBottomRows;
        init(gridOptionsWrapper: GridOptionsWrapper): void;
        setFloatingTopRowData(rowData: any[]): void;
        setFloatingBottomRowData(rowData: any[]): void;
        private createNodesFromData(allData, isTop);
        getFloatingTopRowData(): RowNode[];
        getFloatingBottomRowData(): RowNode[];
        getFloatingTopTotalHeight(): number;
        getFloatingBottomTotalHeight(): number;
        private getTotalHeight(rowNodes);
    }
}
declare module ag.grid {
    class ComponentUtil {
        static EVENTS: string[];
        private static EVENT_CALLBACKS;
        static STRING_PROPERTIES: string[];
        static OBJECT_PROPERTIES: string[];
        static ARRAY_PROPERTIES: string[];
        static NUMBER_PROPERTIES: string[];
        static BOOLEAN_PROPERTIES: string[];
        static FUNCTION_PROPERTIES: string[];
        static ALL_PROPERTIES: string[];
        static getEventCallbacks(): string[];
        static copyAttributesToGridOptions(gridOptions: GridOptions, component: any): GridOptions;
        static getCallbackForEvent(eventName: string): string;
        static processOnChange(changes: any, gridOptions: GridOptions, api: GridApi): void;
        static toBoolean(value: any): boolean;
        static toNumber(value: any): number;
    }
}
declare module ag.grid {
    class GridOptionsWrapper {
        private gridOptions;
        private headerHeight;
        init(gridOptions: GridOptions, eventService: EventService): void;
        isRowSelection(): boolean;
        isRowDeselection(): boolean;
        isRowSelectionMulti(): boolean;
        getContext(): any;
        isVirtualPaging(): boolean;
        isShowToolPanel(): boolean;
        isToolPanelSuppressGroups(): boolean;
        isToolPanelSuppressValues(): boolean;
        isRowsAlreadyGrouped(): boolean;
        isGroupSelectsChildren(): boolean;
        isGroupHideGroupColumns(): boolean;
        isGroupIncludeFooter(): boolean;
        isGroupSuppressBlankHeader(): boolean;
        isSuppressRowClickSelection(): boolean;
        isSuppressCellSelection(): boolean;
        isSuppressMultiSort(): boolean;
        isGroupSuppressAutoColumn(): boolean;
        isForPrint(): boolean;
        isSuppressHorizontalScroll(): boolean;
        isSuppressLoadingOverlay(): boolean;
        isSuppressNoRowsOverlay(): boolean;
        getFloatingTopRowData(): any[];
        getFloatingBottomRowData(): any[];
        isUnSortIcon(): boolean;
        isSuppressMenuHide(): boolean;
        getRowStyle(): any;
        getRowClass(): any;
        getRowStyleFunc(): Function;
        getRowClassFunc(): Function;
        getBusinessKeyForNodeFunc(): (node: RowNode) => string;
        getHeaderCellRenderer(): any;
        getApi(): GridApi;
        isEnableColResize(): boolean;
        isSingleClickEdit(): boolean;
        getGroupDefaultExpanded(): number;
        getGroupAggFunction(): (nodes: any[]) => any;
        getRowData(): any[];
        isGroupUseEntireRow(): boolean;
        getGroupColumnDef(): any;
        isGroupSuppressRow(): boolean;
        isAngularCompileRows(): boolean;
        isAngularCompileFilters(): boolean;
        isAngularCompileHeaders(): boolean;
        isDebug(): boolean;
        getColumnDefs(): any[];
        getDatasource(): any;
        isEnableSorting(): boolean;
        isEnableCellExpressions(): boolean;
        isEnableServerSideSorting(): boolean;
        isEnableFilter(): boolean;
        isEnableServerSideFilter(): boolean;
        isSuppressScrollLag(): boolean;
        getIcons(): any;
        getIsScrollLag(): () => boolean;
        getSortingOrder(): string[];
        getSlaveGrids(): GridOptions[];
        getGroupRowRenderer(): Function | Object;
        getOverlayLoadingTemplate(): string;
        getOverlayNoRowsTemplate(): string;
        getCheckboxSelection(): Function;
        isSuppressAutoSize(): boolean;
        isSuppressParentsInRowNodes(): boolean;
        getHeaderCellTemplate(): string;
        getHeaderCellTemplateFunc(): (params: any) => string | HTMLElement;
        getHeaderHeight(): number;
        setHeaderHeight(headerHeight: number): void;
        isExternalFilterPresent(): boolean;
        doesExternalFilterPass(node: RowNode): boolean;
        getGroupRowInnerRenderer(): (params: any) => void;
        getColWidth(): number;
        getRowBuffer(): number;
        private checkForDeprecated();
        getLocaleTextFunc(): Function;
        globalEventHandler(eventName: string, event?: any): void;
        getRowHeightForVirtualPagiation(): number;
        getRowHeightForNode(rowNode: RowNode): number;
    }
}
declare module ag.grid {
    interface TextAndNumberFilterParameters {
        /** What to do when new rows are loaded. The default is to reset the filter, to keep it in line with 'set' filters. If you want to keep the selection, then set this value to 'keep'. */
        newRowsAction?: string;
    }
}
declare module ag.grid {
    class TextFilter implements Filter {
        private filterParams;
        private filterChangedCallback;
        private filterModifiedCallback;
        private localeTextFunc;
        private valueGetter;
        private filterText;
        private filterType;
        private api;
        private eGui;
        private eFilterTextField;
        private eTypeSelect;
        private applyActive;
        private eApplyButton;
        init(params: any): void;
        onNewRowsLoaded(): void;
        afterGuiAttached(): void;
        doesFilterPass(node: any): boolean;
        getGui(): any;
        isFilterActive(): boolean;
        private createTemplate();
        private createGui();
        private setupApply();
        private onTypeChanged();
        private onFilterChanged();
        private filterChanged();
        private createApi();
        private getApi();
    }
}
declare module ag.grid {
    class NumberFilter implements Filter {
        private filterParams;
        private filterChangedCallback;
        private filterModifiedCallback;
        private localeTextFunc;
        private valueGetter;
        private filterNumber;
        private filterType;
        private api;
        private eGui;
        private eFilterTextField;
        private eTypeSelect;
        private applyActive;
        private eApplyButton;
        init(params: any): void;
        onNewRowsLoaded(): void;
        afterGuiAttached(): void;
        doesFilterPass(node: any): boolean;
        getGui(): any;
        isFilterActive(): boolean;
        private createTemplate();
        private createGui();
        private setupApply();
        private onTypeChanged();
        private filterChanged();
        private onFilterChanged();
        private createApi();
        private getApi();
    }
}
declare module ag.grid {
    /** AbstractColDef can be a group or a column definition */
    interface AbstractColDef {
        /** The name to render in the column header */
        headerName?: string;
        /** Whether to show the column when the group is open / closed. */
        columnGroupShow?: string;
    }
    interface ColGroupDef extends AbstractColDef {
        /** Columns in this group*/
        children: AbstractColDef[];
        /** Group ID */
        groupId?: string;
    }
    interface ColDef extends AbstractColDef {
        /** The unique ID to give the column. This is optional. If missing, the ID will default to the field.
         *  If both field and colId are missing, a unique ID will be generated.
         *  This ID is used to identify the column in the API for sorting, filtering etc. */
        colId?: string;
        /** If sorting by default, set it here. Set to 'asc' or 'desc' */
        sort?: string;
        /** If sorting more than one column by default, the milliseconds when this column was sorted, so we know what order to sort the columns in. */
        sortedAt?: number;
        /** The sort order, provide an array with any of the following in any order ['asc','desc',null] */
        sortingOrder?: string[];
        /** The field of the row to get the cells data from */
        field?: string;
        /** Expression or function to get the cells value. */
        headerValueGetter?: string | Function;
        /** Set to true for this column to be hidden. Naturally you might think, it would make more sense to call this field 'visible' and mark it false to hide,
         *  however we want all default values to be false and we want columns to be visible by default. */
        hide?: boolean;
        /** Whether this column is pinned or not. */
        pinned?: boolean | string;
        /** Tooltip for the column header */
        headerTooltip?: string;
        /** Expression or function to get the cells value. */
        valueGetter?: string | Function;
        /** To provide custom rendering to the header. */
        headerCellRenderer?: Function | Object;
        /** To provide a template for the header. */
        headerCellTemplate?: ((params: any) => string | HTMLElement) | string | HTMLElement;
        /** CSS class for the header */
        headerClass?: string | string[] | ((params: any) => string | string[]);
        /** Initial width, in pixels, of the cell */
        width?: number;
        /** Min width, in pixels, of the cell */
        minWidth?: number;
        /** Max width, in pixels, of the cell */
        maxWidth?: number;
        /** Class to use for the cell. Can be string, array of strings, or function. */
        cellClass?: string | string[] | ((cellClassParams: any) => string | string[]);
        /** An object of css values. Or a function returning an object of css values. */
        cellStyle?: {} | ((params: any) => {});
        /** A function for rendering a cell. */
        cellRenderer?: Function | {};
        /** A function for rendering a floating cell. */
        floatingCellRenderer?: Function | {};
        /** Name of function to use for aggregation. One of [sum,min,max]. */
        aggFunc?: string;
        /** To group by this column by default, provide an index here. */
        rowGroupIndex?: number;
        /** Comparator function for custom sorting. */
        comparator?: (valueA: any, valueB: any, nodeA?: RowNode, nodeB?: RowNode, isInverted?: boolean) => number;
        /** Set to true to render a selection checkbox in the column. */
        checkboxSelection?: boolean | (Function);
        /** Set to true if no menu should be shown for this column header. */
        suppressMenu?: boolean;
        /** Set to true if no sorting should be done for this column. */
        suppressSorting?: boolean;
        /** Set to true if you want the unsorted icon to be shown when no sort is applied to this column. */
        unSortIcon?: boolean;
        /** Set to true if you want this columns width to be fixed during 'size to fit' operation. */
        suppressSizeToFit?: boolean;
        /** Set to true if you do not want this column to be resizable by dragging it's edge. */
        suppressResize?: boolean;
        /** Set to true if you do not want this column to be auto-resizable by double clicking it's edge. */
        suppressAutoSize?: boolean;
        /** Set to true if this col is editable, otherwise false. Can also be a function to have different rows editable. */
        editable?: boolean | (Function);
        /** Callbacks for editing.See editing section for further details. */
        newValueHandler?: Function;
        /** If true, this cell gets refreshed when api.softRefreshView() gets called. */
        volatile?: boolean;
        /** Cell template to use for cell. Useful for AngularJS cells. */
        template?: string;
        /** Cell template URL to load template from to use for cell. Useful for AngularJS cells. */
        templateUrl?: string;
        /** one of the built in filter names: [set, number, text], or a filter function*/
        filter?: string | Function;
        /** The filter params are specific to each filter! */
        filterParams?: SetFilterParameters | TextAndNumberFilterParameters;
        /** Rules for applying css classes */
        cellClassRules?: {
            [cssClassName: string]: (Function | string);
        };
        /** Callbacks for editing.See editing section for further details. */
        onCellValueChanged?: Function;
        /** Function callback, gets called when a cell is clicked. */
        onCellClicked?: Function;
        /** Function callback, gets called when a cell is double clicked. */
        onCellDoubleClicked?: Function;
        /** Function callback, gets called when a cell is right clicked. */
        onCellContextMenu?: Function;
        /** Icons for this column. Leave blank to use default. */
        icons?: {
            [key: string]: string;
        };
    }
}
declare module ag.grid {
    class SetFilterModel {
        private colDef;
        private filterParams;
        private rowModel;
        private valueGetter;
        private allUniqueValues;
        private availableUniqueValues;
        private displayedValues;
        private miniFilter;
        private selectedValuesCount;
        private selectedValuesMap;
        private showingAvailableOnly;
        private usingProvidedSet;
        private doesRowPassOtherFilters;
        constructor(colDef: ColDef, rowModel: any, valueGetter: any, doesRowPassOtherFilters: any);
        refreshAfterNewRowsLoaded(keepSelection: any, isSelectAll: boolean): void;
        refreshAfterAnyFilterChanged(): void;
        private createAllUniqueValues();
        private createAvailableUniqueValues();
        private sortValues(values);
        private getUniqueValues(filterOutNotAvailable);
        setMiniFilter(newMiniFilter: any): boolean;
        getMiniFilter(): any;
        private processMiniFilter();
        getDisplayedValueCount(): number;
        getDisplayedValue(index: any): any;
        selectEverything(): void;
        isFilterActive(): boolean;
        selectNothing(): void;
        getUniqueValueCount(): number;
        getUniqueValue(index: any): any;
        unselectValue(value: any): void;
        selectValue(value: any): void;
        isValueSelected(value: any): boolean;
        isEverythingSelected(): boolean;
        isNothingSelected(): boolean;
        getModel(): any;
        setModel(model: any, isSelectAll: boolean): void;
    }
}
/** The filter parameters for set filter */
declare module ag.grid {
    interface SetFilterParameters {
        /** Same as cell renderer for grid (you can use the same one in both locations). Setting it separatly here allows for the value to be rendered differently in the filter. */
        cellRenderer?: Function;
        /** The height of the cell. */
        cellHeight?: number;
        /** The values to display in the filter. */
        values?: any;
        /**  What to do when new rows are loaded. The default is to reset the filter, as the set of values to select from can have changed. If you want to keep the selection, then set this value to 'keep'. */
        newRowsAction?: string;
        /** If true, the filter will not remove items that are no longer availabe due to other filters. */
        suppressRemoveEntries?: boolean;
        /** Comparator for sorting. If not provided, the colDef comparator is used. If colDef also not provided, the default (agGrid provided) comparator is used.*/
        comparator?: (a: any, b: any) => number;
    }
}
declare module ag.grid {
    class SetFilter implements Filter {
        private eGui;
        private filterParams;
        private rowHeight;
        private model;
        private filterChangedCallback;
        private filterModifiedCallback;
        private valueGetter;
        private rowsInBodyContainer;
        private colDef;
        private localeTextFunc;
        private cellRenderer;
        private eListContainer;
        private eFilterValueTemplate;
        private eSelectAll;
        private eListViewport;
        private eMiniFilter;
        private api;
        private applyActive;
        private eApplyButton;
        init(params: any): void;
        afterGuiAttached(): void;
        isFilterActive(): boolean;
        doesFilterPass(node: any): boolean;
        getGui(): any;
        onNewRowsLoaded(): void;
        onAnyFilterChanged(): void;
        private createTemplate();
        private createGui();
        private setupApply();
        private setContainerHeight();
        private drawVirtualRows();
        private ensureRowsRendered(start, finish);
        private removeVirtualRows(rowsToRemove);
        private insertRow(value, rowIndex);
        private onCheckboxClicked(eCheckbox, value);
        private filterChanged();
        private onMiniFilterChanged();
        private refreshVirtualRows();
        private clearVirtualRows();
        private onSelectAll();
        private updateAllCheckboxes(checked);
        private addScrollListener();
        getApi(): any;
        private createApi();
    }
}
declare module ag.grid {
    class PopupService {
        private ePopupParent;
        init(ePopupParent: any): void;
        positionPopup(eventSource: any, ePopup: any, keepWithinBounds: boolean): void;
        addAsModalPopup(eChild: any, closeOnEsc: boolean): (event: any) => void;
    }
}
declare module ag.grid {
    class FilterManager {
        private $compile;
        private $scope;
        private gridOptionsWrapper;
        private grid;
        private allFilters;
        private rowModel;
        private popupService;
        private valueService;
        private columnController;
        private quickFilter;
        private advancedFilterPresent;
        private externalFilterPresent;
        init(grid: Grid, gridOptionsWrapper: GridOptionsWrapper, $compile: any, $scope: any, columnController: ColumnController, popupService: PopupService, valueService: ValueService): void;
        setFilterModel(model: any): void;
        private setModelOnFilterWrapper(filter, newModel);
        getFilterModel(): any;
        setRowModel(rowModel: any): void;
        isAdvancedFilterPresent(): boolean;
        isAnyFilterPresent(): boolean;
        isFilterPresentForCol(colId: any): any;
        private doesFilterPass(node, filterToSkip?);
        setQuickFilter(newFilter: any): boolean;
        onFilterChanged(): void;
        isQuickFilterPresent(): boolean;
        doesRowPassOtherFilters(filterToSkip: any, node: any): boolean;
        doesRowPassFilter(node: any, filterToSkip?: any): boolean;
        private aggregateRowForQuickFilter(node);
        onNewRowsLoaded(): void;
        private createValueGetter(column);
        getFilterApi(column: Column): any;
        private getOrCreateFilterWrapper(column);
        private createFilterWrapper(column);
        destroy(): void;
        private assertMethodHasNoParameters(theMethod);
        showFilter(column: Column, eventSource: any): void;
    }
}
declare module ag.grid {
    interface ColumnGroupChild {
        getActualWidth(): number;
        getMinimumWidth(): number;
        getDefinition(): AbstractColDef;
        getColumnGroupShow(): string;
    }
}
declare module ag.grid {
    class ColumnGroup implements ColumnGroupChild {
        private children;
        private displayedChildren;
        private groupId;
        private instanceId;
        private expandable;
        private expanded;
        private colGroupDef;
        constructor(colGroupDef: ColGroupDef, groupId: string, instanceId: number);
        getHeaderName(): string;
        getGroupId(): string;
        getInstanceId(): number;
        setExpanded(expanded: boolean): void;
        isExpandable(): boolean;
        isExpanded(): boolean;
        getColGroupDef(): ColGroupDef;
        isChildInThisGroupDeepSearch(wantedChild: ColumnGroupChild): boolean;
        getActualWidth(): number;
        getMinimumWidth(): number;
        addChild(child: ColumnGroupChild): void;
        getDisplayedChildren(): ColumnGroupChild[];
        getDisplayedLeafColumns(): Column[];
        getDefinition(): AbstractColDef;
        private addDisplayedLeafColumns(leafColumns);
        getChildren(): ColumnGroupChild[];
        getColumnGroupShow(): string;
        calculateExpandable(): void;
        calculateDisplayedColumns(): void;
    }
}
declare module ag.grid {
    class Column implements ColumnGroupChild, OriginalColumnGroupChild {
        static PINNED_RIGHT: string;
        static PINNED_LEFT: string;
        static AGG_SUM: string;
        static AGG_MIN: string;
        static AGG_MAX: string;
        static SORT_ASC: string;
        static SORT_DESC: string;
        private colDef;
        private colId;
        private actualWidth;
        private visible;
        private pinned;
        private index;
        private aggFunc;
        private sort;
        private sortedAt;
        constructor(colDef: ColDef, actualWidth: any, colId: String);
        getSort(): string;
        setSort(sort: string): void;
        getSortedAt(): number;
        setSortedAt(sortedAt: number): void;
        setAggFunc(aggFunc: string): void;
        getAggFunc(): string;
        getIndex(): number;
        setIndex(index: number): void;
        setPinned(pinned: string | boolean): void;
        isPinned(): boolean;
        getPinned(): string;
        setVisible(visible: boolean): void;
        isVisible(): boolean;
        getColDef(): ColDef;
        getColumnGroupShow(): string;
        getColId(): string;
        getDefinition(): AbstractColDef;
        getActualWidth(): number;
        setActualWidth(actualWidth: number): void;
        isGreaterThanMax(width: number): boolean;
        getMinimumWidth(): number;
        setMinimum(): void;
    }
}
declare module ag.grid {
    class LoggerFactory {
        private logging;
        init(gridOptionsWrapper: GridOptionsWrapper): void;
        create(name: string): Logger;
    }
    class Logger {
        private logging;
        private name;
        constructor(name: string, logging: boolean);
        log(message: string): void;
    }
}
declare module ag.grid {
    class MasterSlaveService {
        private gridOptionsWrapper;
        private columnController;
        private gridPanel;
        private logger;
        private eventService;
        private consuming;
        init(gridOptionsWrapper: GridOptionsWrapper, columnController: ColumnController, gridPanel: GridPanel, loggerFactory: LoggerFactory, eventService: EventService): void;
        private fireEvent(callback);
        private onEvent(callback);
        private fireColumnEvent(event);
        fireHorizontalScrollEvent(horizontalScroll: number): void;
        onScrollEvent(horizontalScroll: number): void;
        getMasterColumns(event: ColumnChangeEvent): Column[];
        getColumnIds(event: ColumnChangeEvent): string[];
        onColumnEvent(event: ColumnChangeEvent): void;
    }
}
declare module ag.grid {
    class GroupInstanceIdCreator {
        private existingIds;
        getInstanceIdForKey(key: string): number;
    }
}
declare module ag.grid {
    class DisplayedGroupCreator {
        private columnUtils;
        init(columnUtils: ColumnUtils): void;
        createDisplayedGroups(sortedVisibleColumns: Column[], balancedColumnTree: OriginalColumnGroupChild[], groupInstanceIdCreator: GroupInstanceIdCreator): ColumnGroupChild[];
        private createFakePath(balancedColumnTree);
        private getOriginalPathForColumn(balancedColumnTree, column);
    }
}
declare module ag.grid {
    interface OriginalColumnGroupChild {
    }
}
declare module ag.grid {
    class OriginalColumnGroup implements OriginalColumnGroupChild {
        private colGroupDef;
        private children;
        private groupId;
        constructor(colGroupDef: ColGroupDef, groupId: string);
        getGroupId(): string;
        setChildren(children: OriginalColumnGroupChild[]): void;
        getChildren(): OriginalColumnGroupChild[];
        getColGroupDef(): ColGroupDef;
    }
}
declare module ag.grid {
    class ColumnKeyCreator {
        private existingKeys;
        getUniqueKey(colId: string, colField: string): string;
    }
}
declare module ag.grid {
    class BalancedColumnTreeBuilder {
        private gridOptionsWrapper;
        private logger;
        private columnUtils;
        init(gridOptionsWrapper: GridOptionsWrapper, loggerFactory: LoggerFactory, columnUtils: ColumnUtils): void;
        createBalancedColumnGroups(abstractColDefs: AbstractColDef[]): any;
        private balanceColumnTree(unbalancedTree, currentDept, columnDept, columnKeyCreator);
        private findMaxDept(treeChildren, dept);
        private recursivelyCreateColumns(abstractColDefs, level, columnKeyCreator);
        private checkForDeprecatedItems(colDef);
        private isColumnGroup(abstractColDef);
    }
}
declare module ag.grid {
    class AutoWidthCalculator {
        private rowRenderer;
        private gridPanel;
        init(rowRenderer: RowRenderer, gridPanel: GridPanel): void;
        getPreferredWidthForColumn(column: Column): number;
    }
}
declare module ag.grid {
    class ColumnApi {
        private _columnController;
        constructor(_columnController: ColumnController);
        sizeColumnsToFit(gridWidth: any): void;
        setColumnGroupOpened(group: ColumnGroup | string, newValue: boolean, instanceId?: number): void;
        getColumnGroup(name: string, instanceId?: number): ColumnGroup;
        getDisplayNameForCol(column: any): string;
        getColumn(key: any): Column;
        setState(columnState: any): void;
        getState(): [any];
        resetState(): void;
        isPinning(): boolean;
        isPinningLeft(): boolean;
        isPinningRight(): boolean;
        getDisplayedColAfter(col: Column): Column;
        getDisplayedColBefore(col: Column): Column;
        setColumnVisible(key: Column | ColDef | String, visible: boolean): void;
        setColumnsVisible(keys: (Column | ColDef | String)[], visible: boolean): void;
        setColumnPinned(key: Column | ColDef | String, pinned: string): void;
        setColumnsPinned(keys: (Column | ColDef | String)[], pinned: string): void;
        getAllColumns(): Column[];
        getDisplayedLeftColumns(): Column[];
        getDisplayedCenterColumns(): Column[];
        getDisplayedRightColumns(): Column[];
        getRowGroupColumns(): Column[];
        getValueColumns(): Column[];
        moveColumn(fromIndex: number, toIndex: number): void;
        moveRowGroupColumn(fromIndex: number, toIndex: number): void;
        setColumnAggFunction(column: Column, aggFunc: string): void;
        setColumnWidth(key: Column | string | ColDef, newWidth: number, finished?: boolean): void;
        removeValueColumn(column: Column): void;
        addValueColumn(column: Column): void;
        removeRowGroupColumn(column: Column): void;
        addRowGroupColumn(column: Column): void;
        getLeftDisplayedColumnGroups(): ColumnGroupChild[];
        getCenterDisplayedColumnGroups(): ColumnGroupChild[];
        getRightDisplayedColumnGroups(): ColumnGroupChild[];
        getAllDisplayedColumnGroups(): ColumnGroupChild[];
        autoSizeColumn(key: Column | ColDef | String): void;
        autoSizeColumns(keys: (Column | ColDef | String)[]): void;
        columnGroupOpened(group: ColumnGroup | string, newValue: boolean): void;
        hideColumns(colIds: any, hide: any): void;
        hideColumn(colId: any, hide: any): void;
    }
    class ColumnController {
        private gridOptionsWrapper;
        private angularGrid;
        private selectionRendererFactory;
        private expressionService;
        private masterSlaveController;
        private balancedColumnTreeBuilder;
        private displayedGroupCreator;
        private autoWidthCalculator;
        private originalBalancedTree;
        private allColumns;
        private displayedLeftColumnTree;
        private displayedRightColumnTree;
        private displayedCentreColumnTree;
        private displayedLeftColumns;
        private displayedRightColumns;
        private displayedCenterColumns;
        private headerRowCount;
        private rowGroupColumns;
        private valueColumns;
        private groupAutoColumn;
        private setupComplete;
        private valueService;
        private eventService;
        private columnUtils;
        private logger;
        constructor();
        init(angularGrid: Grid, selectionRendererFactory: SelectionRendererFactory, gridOptionsWrapper: GridOptionsWrapper, expressionService: ExpressionService, valueService: ValueService, masterSlaveController: MasterSlaveService, eventService: EventService, balancedColumnTreeBuilder: BalancedColumnTreeBuilder, displayedGroupCreator: DisplayedGroupCreator, columnUtils: ColumnUtils, autoWidthCalculator: AutoWidthCalculator, loggerFactory: LoggerFactory): void;
        autoSizeColumns(keys: (Column | ColDef | String)[]): void;
        autoSizeColumn(key: Column | String | ColDef): void;
        private getColumnsFromTree(rootColumns);
        getAllDisplayedColumnGroups(): ColumnGroupChild[];
        getColumnApi(): ColumnApi;
        isSetupComplete(): boolean;
        getHeaderRowCount(): number;
        getLeftDisplayedColumnGroups(): ColumnGroupChild[];
        getRightDisplayedColumnGroups(): ColumnGroupChild[];
        getCenterDisplayedColumnGroups(): ColumnGroupChild[];
        getAllDisplayedColumns(): Column[];
        getPinnedLeftContainerWidth(): number;
        getPinnedRightContainerWidth(): number;
        addRowGroupColumn(column: Column): void;
        removeRowGroupColumn(column: Column): void;
        addValueColumn(column: Column): void;
        removeValueColumn(column: Column): void;
        private doesColumnExistInGrid(column);
        getFirstRightPinnedColIndex(): number;
        private normaliseColumnWidth(column, newWidth);
        setColumnWidth(key: Column | string | ColDef, newWidth: number, finished: boolean): void;
        setColumnAggFunction(column: Column, aggFunc: string): void;
        moveRowGroupColumn(fromIndex: number, toIndex: number): void;
        moveColumn(fromIndex: number, toIndex: number): void;
        getBodyContainerWidth(): number;
        getValueColumns(): Column[];
        getRowGroupColumns(): Column[];
        getDisplayedCenterColumns(): Column[];
        getDisplayedLeftColumns(): Column[];
        getDisplayedRightColumns(): Column[];
        getAllColumns(): Column[];
        setColumnVisible(key: Column | ColDef | String, visible: boolean): void;
        setColumnsVisible(keys: (Column | ColDef | String)[], visible: boolean): void;
        setColumnPinned(key: Column | ColDef | String, pinned: string | boolean): void;
        setColumnsPinned(keys: (Column | ColDef | String)[], pinned: string | boolean): void;
        private actionOnColumns(keys, action, createEvent);
        getDisplayedColBefore(col: any): Column;
        getDisplayedColAfter(col: Column): Column;
        isPinningLeft(): boolean;
        isPinningRight(): boolean;
        getState(): [any];
        resetState(): void;
        setState(columnState: any[]): void;
        getColumns(keys: any[]): Column[];
        getColumn(key: any): Column;
        getDisplayNameForCol(column: any): string;
        getColumnGroup(colId: string | ColumnGroup, instanceId?: number): ColumnGroup;
        onColumnsChanged(): void;
        private extractRowGroupColumns();
        setColumnGroupOpened(passedGroup: ColumnGroup | string, newValue: boolean, instanceId?: number): void;
        private updateModel();
        private updateGroupsAndDisplayedColumns();
        private updateDisplayedColumnsFromGroups();
        sizeColumnsToFit(gridWidth: any): void;
        private buildAllGroups(visibleColumns);
        private updateGroups();
        private createGroupAutoColumn();
        private updateVisibleColumns();
        private createValueColumns();
        private getWithOfColsInList(columnList);
    }
}
declare module ag.grid {
    class SvgFactory {
        static theInstance: SvgFactory;
        static getInstance(): SvgFactory;
        createFilterSvg(): Element;
        createColumnShowingSvg(): Element;
        createColumnHiddenSvg(): Element;
        createMenuSvg(): Element;
        createArrowUpSvg(): Element;
        createArrowLeftSvg(): Element;
        createArrowDownSvg(): Element;
        createArrowRightSvg(): Element;
        createSmallArrowDownSvg(): Element;
        createArrowUpDownSvg(): Element;
    }
}
declare module ag.grid {
    class HeaderTemplateLoader {
        private static HEADER_CELL_TEMPLATE;
        private gridOptionsWrapper;
        init(gridOptionsWrapper: GridOptionsWrapper): void;
        createHeaderElement(column: Column): HTMLElement;
        createDefaultHeaderElement(column: Column): HTMLElement;
        private addInIcon(eTemplate, iconName, cssSelector, column, defaultIconFactory);
    }
}
declare module ag.grid {
    class TemplateService {
        templateCache: any;
        waitingCallbacks: any;
        $scope: any;
        init($scope: any): void;
        getTemplate(url: any, callback: any): any;
        handleHttpResult(httpResult: any, url: any): void;
    }
}
declare module ag.grid {
    class SelectionRendererFactory {
        private grid;
        private selectionController;
        init(grid: Grid, selectionController: any): void;
        createSelectionCheckbox(node: any, rowIndex: any): HTMLInputElement;
    }
}
declare module ag.vdom {
    class VElement {
        static idSequence: number;
        private id;
        private elementAttachedListeners;
        constructor();
        getId(): number;
        addElementAttachedListener(listener: (element: Element) => void): void;
        protected fireElementAttached(element: Element): void;
        elementAttached(element: Element): void;
        toHtmlString(): string;
    }
}
declare module ag.vdom {
    class VHtmlElement extends VElement {
        private type;
        private classes;
        private eventListeners;
        private attributes;
        private children;
        private innerHtml;
        private style;
        private bound;
        private element;
        constructor(type: string);
        getElement(): HTMLElement;
        setInnerHtml(innerHtml: string): void;
        addStyles(styles: any): void;
        private attachEventListeners(node);
        addClass(newClass: string): void;
        removeClass(oldClass: string): void;
        addClasses(classes: string[]): void;
        toHtmlString(): string;
        private toHtmlStringChildren();
        private toHtmlStringAttributes();
        private toHtmlStringClasses();
        private toHtmlStringStyles();
        appendChild(child: any): void;
        setAttribute(key: string, value: string): void;
        addEventListener(event: string, listener: EventListener): void;
        elementAttached(element: Element): void;
        fireElementAttachedToChildren(element: Element): void;
    }
}
declare module ag.vdom {
    class VWrapperElement extends VElement {
        private wrappedElement;
        constructor(wrappedElement: Element);
        toHtmlString(): string;
        elementAttached(element: Element): void;
    }
}
declare module ag.grid {
    class RenderedCell {
        private vGridCell;
        private vSpanWithValue;
        private vCellWrapper;
        private vParentOfValue;
        private checkboxOnChangeListener;
        private column;
        private data;
        private node;
        private rowIndex;
        private colIndex;
        private editingCell;
        private scope;
        private firstRightPinnedColumn;
        private gridOptionsWrapper;
        private expressionService;
        private selectionRendererFactory;
        private rowRenderer;
        private selectionController;
        private $compile;
        private templateService;
        private cellRendererMap;
        private eCheckbox;
        private columnController;
        private valueService;
        private eventService;
        private value;
        private checkboxSelection;
        constructor(firstRightPinnedCol: boolean, column: any, $compile: any, rowRenderer: RowRenderer, gridOptionsWrapper: GridOptionsWrapper, expressionService: ExpressionService, selectionRendererFactory: SelectionRendererFactory, selectionController: SelectionController, templateService: TemplateService, cellRendererMap: {
            [key: string]: any;
        }, node: any, rowIndex: number, colIndex: number, scope: any, columnController: ColumnController, valueService: ValueService, eventService: EventService);
        calculateCheckboxSelection(): any;
        getColumn(): Column;
        private getValue();
        getVGridCell(): ag.vdom.VHtmlElement;
        private getDataForRow();
        private setupComponents();
        startEditing(key?: number): void;
        focusCell(forceBrowserFocus: boolean): void;
        private stopEditing(eInput, blurListener, reset?);
        private createParams();
        private createEvent(event, eventSource);
        private addCellDoubleClickedHandler();
        private addCellContextMenuHandler();
        isCellEditable(): any;
        private addCellClickedHandler();
        private populateCell();
        private addStylesFromCollDef();
        private addClassesFromCollDef();
        private addClassesFromRules();
        private addCellNavigationHandler();
        private isKeycodeForStartEditing(key);
        createSelectionCheckbox(): void;
        setSelected(state: boolean): void;
        private createParentOfValue();
        isVolatile(): boolean;
        refreshCell(): void;
        private putDataIntoCell();
        private useCellRenderer(cellRenderer);
        private addClasses();
    }
}
declare module ag.grid {
    class RenderedRow {
        vPinnedLeftRow: any;
        vPinnedRightRow: any;
        vBodyRow: any;
        private renderedCells;
        private scope;
        private node;
        private rowIndex;
        private cellRendererMap;
        private gridOptionsWrapper;
        private parentScope;
        private angularGrid;
        private columnController;
        private expressionService;
        private rowRenderer;
        private selectionRendererFactory;
        private $compile;
        private templateService;
        private selectionController;
        private pinningLeft;
        private pinningRight;
        private eBodyContainer;
        private ePinnedLeftContainer;
        private ePinnedRightContainer;
        private valueService;
        private eventService;
        constructor(gridOptionsWrapper: GridOptionsWrapper, valueService: ValueService, parentScope: any, angularGrid: Grid, columnController: ColumnController, expressionService: ExpressionService, cellRendererMap: {
            [key: string]: any;
        }, selectionRendererFactory: SelectionRendererFactory, $compile: any, templateService: TemplateService, selectionController: SelectionController, rowRenderer: RowRenderer, eBodyContainer: HTMLElement, ePinnedLeftContainer: HTMLElement, ePinnedRightContainer: HTMLElement, node: RowNode, rowIndex: number, eventService: EventService);
        onRowSelected(selected: boolean): void;
        softRefresh(): void;
        getRenderedCellForColumn(column: Column): RenderedCell;
        getCellForCol(column: Column): HTMLElement;
        destroy(): void;
        private destroyScope();
        isDataInList(rows: any[]): boolean;
        isNodeInList(nodes: RowNode[]): boolean;
        isGroup(): boolean;
        private drawNormalRow();
        private bindVirtualElement(vElement);
        private createGroupRow();
        private createGroupSpanningEntireRowCell(padding);
        setMainRowWidth(width: number): void;
        private createChildScopeOrNull(data);
        private addDynamicStyles();
        private createParams();
        private createEvent(event, eventSource);
        private createRowContainer();
        getRowNode(): any;
        getRowIndex(): any;
        refreshCells(colIds: string[]): void;
        private addDynamicClasses();
    }
}
declare module ag.grid {
    function groupCellRendererFactory(gridOptionsWrapper: GridOptionsWrapper, selectionRendererFactory: SelectionRendererFactory, expressionService: ExpressionService, eventService: EventService): (params: any) => HTMLSpanElement;
}
declare module ag.grid {
    class RowRenderer {
        private columnModel;
        private gridOptionsWrapper;
        private angularGrid;
        private selectionRendererFactory;
        private gridPanel;
        private $compile;
        private $scope;
        private selectionController;
        private expressionService;
        private templateService;
        private cellRendererMap;
        private rowModel;
        private firstVirtualRenderedRow;
        private lastVirtualRenderedRow;
        private focusedCell;
        private valueService;
        private eventService;
        private floatingRowModel;
        private renderedRows;
        private renderedTopFloatingRows;
        private renderedBottomFloatingRows;
        private eAllBodyContainers;
        private eAllPinnedLeftContainers;
        private eAllPinnedRightContainers;
        private eBodyContainer;
        private eBodyViewport;
        private ePinnedLeftColsContainer;
        private ePinnedRightColsContainer;
        private eFloatingTopContainer;
        private eFloatingTopPinnedLeftContainer;
        private eFloatingTopPinnedRightContainer;
        private eFloatingBottomContainer;
        private eFloatingBottomPinnedLeftContainer;
        private eFloatingBottomPinnedRightContainer;
        private eParentsOfRows;
        init(columnModel: any, gridOptionsWrapper: GridOptionsWrapper, gridPanel: GridPanel, angularGrid: Grid, selectionRendererFactory: SelectionRendererFactory, $compile: any, $scope: any, selectionController: SelectionController, expressionService: ExpressionService, templateService: TemplateService, valueService: ValueService, eventService: EventService, floatingRowModel: FloatingRowModel): void;
        setRowModel(rowModel: any): void;
        getAllCellsForColumn(column: Column): HTMLElement[];
        onIndividualColumnResized(column: Column): void;
        setMainRowWidths(): void;
        private findAllElements(gridPanel);
        refreshAllFloatingRows(): void;
        private refreshFloatingRows(renderedRows, rowNodes, pinnedLeftContainer, pinnedRightContainer, bodyContainer);
        refreshView(refreshFromIndex?: any): void;
        softRefreshView(): void;
        refreshRows(rowNodes: RowNode[]): void;
        refreshCells(rowNodes: RowNode[], colIds: string[]): void;
        rowDataChanged(rows: any): void;
        destroy(): void;
        private refreshAllVirtualRows(fromIndex);
        refreshGroupRows(): void;
        private removeVirtualRow(rowsToRemove, fromIndex?);
        private unbindVirtualRow(indexToRemove);
        drawVirtualRows(): void;
        workOutFirstAndLastRowsToRender(): void;
        getFirstVirtualRenderedRow(): number;
        getLastVirtualRenderedRow(): number;
        private ensureRowsRendered();
        private insertRow(node, rowIndex, mainRowWidth);
        getRenderedNodes(): any[];
        getIndexOfRenderedNode(node: any): number;
        navigateToNextCell(key: any, rowIndex: number, column: Column): void;
        private getNextCellToFocus(key, lastCellToFocus);
        onRowSelected(rowIndex: number, selected: boolean): void;
        focusCell(eCell: any, rowIndex: number, colIndex: number, colDef: ColDef, forceBrowserFocus: any): void;
        getFocusedCell(): any;
        setFocusedCell(rowIndex: any, colIndex: any): void;
        startEditingNextCell(rowIndex: any, column: any, shiftKey: any): void;
    }
}
declare module ag.grid {
    class SelectionController {
        private eParentsOfRows;
        private angularGrid;
        private gridOptionsWrapper;
        private $scope;
        private rowRenderer;
        private selectedRows;
        private selectedNodesById;
        private rowModel;
        private eventService;
        init(angularGrid: Grid, gridPanel: GridPanel, gridOptionsWrapper: GridOptionsWrapper, $scope: any, rowRenderer: RowRenderer, eventService: EventService): void;
        private initSelectedNodesById();
        getSelectedNodesById(): any;
        getSelectedRows(): any;
        getSelectedNodes(): any;
        getBestCostNodeSelection(): any;
        setRowModel(rowModel: any): void;
        deselectAll(): void;
        selectAll(): void;
        selectNode(node: any, tryMulti: any, suppressEvents?: any): void;
        private recursivelySelectAllChildren(node, suppressEvents?);
        private recursivelyDeselectAllChildren(node, suppressEvents);
        private doWorkOfSelectNode(node, suppressEvents);
        private addCssClassForNode_andInformVirtualRowListener(node);
        private doWorkOfDeselectAllNodes(nodeToKeepSelected, suppressEvents);
        private deselectRealNode(node, suppressEvents);
        private removeCssClassForNode(node);
        deselectIndex(rowIndex: any, suppressEvents?: boolean): void;
        deselectNode(node: any, suppressEvents?: boolean): void;
        selectIndex(index: any, tryMulti: boolean, suppressEvents?: boolean): void;
        private syncSelectedRowsAndCallListener(suppressEvents?);
        private recursivelyCheckIfSelected(node);
        isNodeSelected(node: any): boolean;
        private updateGroupParentsIfNeeded();
    }
}
declare module ag.grid {
    class RenderedHeaderElement {
        private eRoot;
        private dragStartX;
        constructor(eRoot: HTMLElement);
        destroy(): void;
        refreshFilterIcon(): void;
        refreshSortIcon(): void;
        onDragStart(): void;
        onDragging(dragChange: number, finished: boolean): void;
        onIndividualColumnResized(column: Column): void;
        getGui(): HTMLElement;
        addDragHandler(eDraggableElement: any): void;
        stopDragging(listenersToRemove: any, dragChange: number): void;
    }
}
declare module ag.grid {
    class RenderedHeaderCell extends RenderedHeaderElement {
        private static DEFAULT_SORTING_ORDER;
        private parentGroup;
        private eHeaderCell;
        private eSortAsc;
        private eSortDesc;
        private eSortNone;
        private eFilterIcon;
        private eText;
        private column;
        private parentScope;
        private childScope;
        private gridOptionsWrapper;
        private filterManager;
        private columnController;
        private $compile;
        private grid;
        private headerTemplateLoader;
        private startWidth;
        constructor(column: Column, parentGroup: RenderedHeaderGroupCell, gridOptionsWrapper: GridOptionsWrapper, parentScope: any, filterManager: FilterManager, columnController: ColumnController, $compile: any, angularGrid: Grid, eRoot: HTMLElement, headerTemplateLoader: HeaderTemplateLoader);
        getGui(): HTMLElement;
        destroy(): void;
        private createScope();
        private addAttributes();
        private addMenu();
        private removeSortIcons();
        private addSortIcons();
        private setupComponents();
        private addSort();
        private addResize();
        private useRenderer(headerNameValue, headerCellRenderer);
        refreshFilterIcon(): void;
        refreshSortIcon(): void;
        private getNextSortDirection();
        private addSortHandling();
        onDragStart(): void;
        onDragging(dragChange: number, finished: boolean): void;
        onIndividualColumnResized(column: Column): void;
        private addHeaderClassesFromCollDef();
    }
}
declare module ag.grid {
    class RenderedHeaderGroupCell extends RenderedHeaderElement {
        private eHeaderGroupCell;
        private eHeaderCellResize;
        private columnGroup;
        private gridOptionsWrapper;
        private columnController;
        private groupWidthStart;
        private childrenWidthStarts;
        private parentScope;
        private filterManager;
        private $compile;
        private angularGrid;
        constructor(columnGroup: ColumnGroup, gridOptionsWrapper: GridOptionsWrapper, columnController: ColumnController, eRoot: HTMLElement, angularGrid: Grid, parentScope: any, filterManager: FilterManager, $compile: any);
        getGui(): HTMLElement;
        onIndividualColumnResized(column: Column): void;
        private setupComponents();
        private setWidthOfGroupHeaderCell();
        private addGroupExpandIcon(eGroupCellLabel);
        onDragStart(): void;
        onDragging(dragChange: any, finished: boolean): void;
    }
}
declare module ag.grid {
    class HeaderRenderer {
        private headerTemplateLoader;
        private gridOptionsWrapper;
        private columnController;
        private angularGrid;
        private filterManager;
        private $scope;
        private $compile;
        private ePinnedLeftHeader;
        private ePinnedRightHeader;
        private eHeaderContainer;
        private eHeaderViewport;
        private eRoot;
        private headerElements;
        init(gridOptionsWrapper: GridOptionsWrapper, columnController: ColumnController, gridPanel: GridPanel, angularGrid: Grid, filterManager: FilterManager, $scope: any, $compile: any, headerTemplateLoader: HeaderTemplateLoader): void;
        private findAllElements(gridPanel);
        refreshHeader(): void;
        private addTreeNodesAtDept(cellTree, dept, result);
        setPinnedColContainerWidth(): void;
        private insertHeaderRowsIntoContainer(cellTree, eContainerToAddTo);
        private createHeaderElement(columnGroupChild);
        updateSortIcons(): void;
        updateFilterIcons(): void;
        onIndividualColumnResized(column: Column): void;
    }
}
declare module ag.grid {
    class GroupCreator {
        private valueService;
        private gridOptionsWrapper;
        init(valueService: ValueService, gridOptionsWrapper: GridOptionsWrapper): void;
        group(rowNodes: RowNode[], groupedCols: Column[], expandByDefault: number): RowNode[];
        isExpanded(expandByDefault: any, level: any): boolean;
    }
}
declare module ag.grid {
    class InMemoryRowController {
        private gridOptionsWrapper;
        private columnController;
        private angularGrid;
        private filterManager;
        private $scope;
        private allRows;
        private rowsAfterGroup;
        private rowsAfterFilter;
        private rowsAfterSort;
        private rowsToDisplay;
        private model;
        private groupCreator;
        private valueService;
        private eventService;
        constructor();
        init(gridOptionsWrapper: GridOptionsWrapper, columnController: ColumnController, angularGrid: any, filterManager: FilterManager, $scope: any, groupCreator: GroupCreator, valueService: ValueService, eventService: EventService): void;
        private createModel();
        getRowAtPixel(pixelToMatch: number): number;
        private isRowInPixel(rowNode, pixelToMatch);
        getVirtualRowCombinedHeight(): number;
        getModel(): any;
        forEachInMemory(callback: Function): void;
        forEachNode(callback: Function): void;
        forEachNodeAfterFilter(callback: Function): void;
        forEachNodeAfterFilterAndSort(callback: Function): void;
        private recursivelyWalkNodesAndCallback(nodes, callback, recursionType, index);
        updateModel(step: any): void;
        private ensureRowHasHeight(rowNode);
        private defaultGroupAggFunctionFactory(valueColumns);
        doAggregate(): void;
        expandOrCollapseAll(expand: boolean, rowNodes: RowNode[]): void;
        private recursivelyClearAggData(nodes);
        private recursivelyCreateAggData(nodes, groupAggFunction, level);
        private doSort();
        private recursivelyResetSort(rowNodes);
        private sortList(nodes, sortOptions);
        private updateChildIndexes(nodes);
        onRowGroupChanged(): void;
        private doRowGrouping();
        private doFilter();
        private filterItems(rowNodes);
        private recursivelyResetFilter(nodes);
        setAllRows(rows: RowNode[], firstId?: number): void;
        private recursivelyAddIdToNodes(nodes, index);
        private recursivelyCheckUserProvidedNodes(nodes, parent, level);
        private getTotalChildCount(rowNodes);
        private nextRowTop;
        private doRowsToDisplay();
        private recursivelyAddToRowsToDisplay(rowNodes);
        private addRowNodeToRowsToDisplay(rowNode);
        private createFooterNode(groupNode);
    }
}
declare module ag.grid {
    class VirtualPageRowController {
        rowRenderer: any;
        datasourceVersion: any;
        gridOptionsWrapper: GridOptionsWrapper;
        angularGrid: any;
        datasource: any;
        virtualRowCount: any;
        foundMaxRow: any;
        pageCache: {
            [key: string]: RowNode[];
        };
        pageCacheSize: any;
        pageLoadsInProgress: any;
        pageLoadsQueued: any;
        pageAccessTimes: any;
        accessTime: any;
        maxConcurrentDatasourceRequests: any;
        maxPagesInCache: any;
        pageSize: any;
        overflowSize: any;
        init(rowRenderer: any, gridOptionsWrapper: any, angularGrid: any): void;
        setDatasource(datasource: any): void;
        reset(): void;
        createNodesFromRows(pageNumber: any, rows: any): any;
        private createNode(data, virtualRowIndex);
        removeFromLoading(pageNumber: any): void;
        pageLoadFailed(pageNumber: any): void;
        pageLoaded(pageNumber: any, rows: any, lastRow: any): void;
        putPageIntoCacheAndPurge(pageNumber: any, rows: any): void;
        checkMaxRowAndInformRowRenderer(pageNumber: any, lastRow: any): void;
        isPageAlreadyLoading(pageNumber: any): boolean;
        doLoadOrQueue(pageNumber: any): void;
        addToQueueAndPurgeQueue(pageNumber: any): void;
        findLeastRecentlyAccessedPage(pageIndexes: any): number;
        checkQueueForNextLoad(): void;
        loadPage(pageNumber: any): void;
        requestIsDaemon(datasourceVersionCopy: any): boolean;
        getVirtualRow(rowIndex: any): RowNode;
        forEachNode(callback: any): void;
        getRowHeightAsNumber(): number;
        getVirtualRowCombinedHeight(): number;
        getRowAtPixel(pixel: number): number;
        getModel(): {
            getRowAtPixel: (pixel: number) => number;
            getVirtualRowCombinedHeight: () => number;
            getVirtualRow: (index: any) => RowNode;
            getVirtualRowCount: () => any;
            forEachInMemory: (callback: any) => void;
            forEachNode: (callback: any) => void;
            forEachNodeAfterFilter: (callback: any) => void;
            forEachNodeAfterFilterAndSort: (callback: any) => void;
        };
    }
}
declare module ag.grid {
    class PaginationController {
        private eGui;
        private btNext;
        private btPrevious;
        private btFirst;
        private btLast;
        private lbCurrent;
        private lbTotal;
        private lbRecordCount;
        private lbFirstRowOnPage;
        private lbLastRowOnPage;
        private ePageRowSummaryPanel;
        private angularGrid;
        private callVersion;
        private gridOptionsWrapper;
        private datasource;
        private pageSize;
        private rowCount;
        private foundMaxRow;
        private totalPages;
        private currentPage;
        init(angularGrid: any, gridOptionsWrapper: any): void;
        setDatasource(datasource: any): void;
        reset(): void;
        private myToLocaleString(input);
        private setTotalLabels();
        private calculateTotalPages();
        private pageLoaded(rows, lastRowIndex);
        private updateRowLabels();
        private loadPage();
        private isCallDaemon(versionCopy);
        private onBtNext();
        private onBtPrevious();
        private onBtFirst();
        private onBtLast();
        private isZeroPagesToDisplay();
        private enableOrDisableButtons();
        private createTemplate();
        getGui(): any;
        private setupComponents();
    }
}
declare module ag.grid {
    class BorderLayout {
        private eNorthWrapper;
        private eSouthWrapper;
        private eEastWrapper;
        private eWestWrapper;
        private eCenterWrapper;
        private eOverlayWrapper;
        private eCenterRow;
        private eNorthChildLayout;
        private eSouthChildLayout;
        private eEastChildLayout;
        private eWestChildLayout;
        private eCenterChildLayout;
        private isLayoutPanel;
        private fullHeight;
        private layoutActive;
        private eGui;
        private id;
        private childPanels;
        private centerHeightLastTime;
        private sizeChangeListeners;
        private overlays;
        constructor(params: any);
        addSizeChangeListener(listener: Function): void;
        fireSizeChanged(): void;
        private setupPanels(params);
        private setupPanel(content, ePanel);
        getGui(): any;
        doLayout(): boolean;
        private layoutChild(childPanel);
        private layoutHeight();
        private layoutHeightFullHeight();
        private layoutHeightNormal();
        getCentreHeight(): number;
        private layoutWidth();
        setEastVisible(visible: any): void;
        private setupOverlays();
        hideOverlay(): void;
        showOverlay(key: string): void;
        setSouthVisible(visible: any): void;
    }
}
declare module ag.grid {
    class GridPanel {
        private masterSlaveService;
        private gridOptionsWrapper;
        private columnModel;
        private rowRenderer;
        private rowModel;
        private floatingRowModel;
        private layout;
        private logger;
        private forPrint;
        private scrollWidth;
        private scrollLagCounter;
        private eBodyViewport;
        private eRoot;
        private eBody;
        private eBodyContainer;
        private ePinnedLeftColsContainer;
        private ePinnedRightColsContainer;
        private eHeaderContainer;
        private ePinnedLeftHeader;
        private ePinnedRightHeader;
        private eHeader;
        private eParentsOfRows;
        private eBodyViewportWrapper;
        private ePinnedLeftColsViewport;
        private ePinnedRightColsViewport;
        private eHeaderViewport;
        private eFloatingTop;
        private ePinnedLeftFloatingTop;
        private ePinnedRightFloatingTop;
        private eFloatingTopContainer;
        private eFloatingBottom;
        private ePinnedLeftFloatingBottom;
        private ePinnedRightFloatingBottom;
        private eFloatingBottomContainer;
        private lastLeftPosition;
        private lastTopPosition;
        init(gridOptionsWrapper: GridOptionsWrapper, columnModel: ColumnController, rowRenderer: RowRenderer, masterSlaveService: MasterSlaveService, loggerFactory: LoggerFactory, floatingRowModel: FloatingRowModel): void;
        getLayout(): BorderLayout;
        private setupComponents();
        getPinnedLeftFloatingTop(): HTMLElement;
        getPinnedRightFloatingTop(): HTMLElement;
        getFloatingTopContainer(): HTMLElement;
        getPinnedLeftFloatingBottom(): HTMLElement;
        getPinnedRightFloatingBottom(): HTMLElement;
        getFloatingBottomContainer(): HTMLElement;
        private createOverlayTemplate(name, defaultTemplate, userProvidedTemplate);
        private createLoadingOverlayTemplate();
        private createNoRowsOverlayTemplate();
        ensureIndexVisible(index: any): void;
        isHorizontalScrollShowing(): boolean;
        isVerticalScrollShowing(): boolean;
        periodicallyCheck(): void;
        ensureColIndexVisible(index: any): void;
        showLoadingOverlay(): void;
        showNoRowsOverlay(): void;
        hideOverlay(): void;
        private getWidthForSizeColsToFit();
        sizeColumnsToFit(nextTimeout?: number): void;
        setRowModel(rowModel: any): void;
        getBodyContainer(): HTMLElement;
        getBodyViewport(): HTMLElement;
        getPinnedLeftColsContainer(): HTMLElement;
        getPinnedRightColsContainer(): HTMLElement;
        getHeaderContainer(): HTMLElement;
        getRoot(): HTMLElement;
        getPinnedLeftHeader(): HTMLElement;
        getPinnedRightHeader(): HTMLElement;
        getRowsParent(): HTMLElement[];
        private queryHtmlElement(selector);
        private findElements();
        getHeaderViewport(): HTMLElement;
        private centerMouseWheelListener(event);
        private pinnedLeftMouseWheelListener(event);
        private generalMouseWheelListener(event, targetPanel);
        setBodyContainerWidth(): void;
        setPinnedColContainerWidth(): void;
        showPinnedColContainersIfNeeded(): void;
        onBodyHeightChange(): void;
        private sizeHeaderAndBody();
        private sizeHeaderAndBodyNormal();
        private sizeHeaderAndBodyForPrint();
        setHorizontalScrollPosition(hScrollPosition: number): void;
        private addScrollListener();
        private requestDrawVirtualRows();
        private horizontallyScrollHeaderCenterAndFloatingCenter(bodyLeftPosition);
        private verticallyScrollLeftPinned(bodyTopPosition);
        private verticallyScrollBody(position);
    }
}
declare module ag.grid {
    class DragAndDropService {
        private dragItem;
        private mouseUpEventListener;
        private logger;
        init(loggerFactory: LoggerFactory): void;
        destroy(): void;
        private stopDragging();
        private setDragCssClasses(eListItem, dragging);
        addDragSource(eDragSource: any, dragSourceCallback: any): void;
        private onMouseDownDragSource(eDragSource, dragSourceCallback);
        addDropTarget(eDropTarget: any, dropTargetCallback: any): void;
    }
}
declare module ag.grid {
    class AgList {
        private eGui;
        private uniqueId;
        private modelChangedListeners;
        private itemSelectedListeners;
        private beforeDropListeners;
        private itemMovedListeners;
        private dragSources;
        private emptyMessage;
        private eFilterValueTemplate;
        private eListParent;
        private model;
        private cellRenderer;
        private readOnly;
        private dragAndDropService;
        constructor(dragAndDropService: DragAndDropService);
        setReadOnly(readOnly: boolean): void;
        setEmptyMessage(emptyMessage: any): void;
        getUniqueId(): any;
        addStyles(styles: any): void;
        addCssClass(cssClass: any): void;
        addDragSource(dragSource: any): void;
        addModelChangedListener(listener: Function): void;
        addItemSelectedListener(listener: any): void;
        addItemMovedListener(listener: any): void;
        addBeforeDropListener(listener: any): void;
        private fireItemMoved(fromIndex, toIndex);
        private fireModelChanged();
        private fireItemSelected(item);
        private fireBeforeDrop(item);
        private setupComponents();
        setModel(model: any): void;
        getModel(): any;
        setCellRenderer(cellRenderer: any): void;
        refreshView(): void;
        private insertRows();
        private insertBlankMessage();
        private setupAsDropTarget();
        private externalAcceptDrag(dragEvent);
        private externalDrop(dragEvent);
        private externalNoDrop();
        private addItemToList(newItem);
        private addDragAndDropToListItem(eListItem, item);
        private internalAcceptDrag(targetColumn, dragItem, eListItem);
        private internalDrop(targetColumn, draggedColumn);
        private internalNoDrop(eListItem);
        private dragAfterThisItem(targetColumn, draggedColumn);
        private setDropCssClasses(eListItem, state);
        getGui(): any;
    }
}
declare module ag.grid {
    class ColumnSelectionPanel {
        private gridOptionsWrapper;
        private columnController;
        private cColumnList;
        layout: any;
        private eRootPanel;
        private dragAndDropService;
        constructor(columnController: ColumnController, gridOptionsWrapper: GridOptionsWrapper, eventService: EventService, dragAndDropService: DragAndDropService);
        private columnsChanged();
        getDragSource(): any;
        private columnCellRenderer(params);
        private setupComponents();
        private onItemMoved(fromIndex, toIndex);
        getGui(): any;
    }
}
declare module ag.grid {
    class GroupSelectionPanel {
        private gridOptionsWrapper;
        private columnController;
        private inMemoryRowController;
        private cColumnList;
        layout: any;
        private dragAndDropService;
        constructor(columnController: ColumnController, inMemoryRowController: any, gridOptionsWrapper: GridOptionsWrapper, eventService: EventService, dragAndDropService: DragAndDropService);
        private columnsChanged();
        addDragSource(dragSource: any): void;
        private columnCellRenderer(params);
        private setupComponents();
        private onBeforeDrop(newItem);
        private onItemMoved(fromIndex, toIndex);
    }
}
declare module ag.grid {
    class AgDropdownList {
        private itemSelectedListeners;
        private eValue;
        private agList;
        private eGui;
        private hidePopupCallback;
        private selectedItem;
        private cellRenderer;
        private popupService;
        constructor(popupService: PopupService, dragAndDropService: DragAndDropService);
        setWidth(width: any): void;
        addItemSelectedListener(listener: any): void;
        fireItemSelected(item: any): void;
        setupComponents(dragAndDropService: DragAndDropService): void;
        itemSelected(item: any): void;
        onClick(): void;
        getGui(): any;
        setSelected(item: any): void;
        setCellRenderer(cellRenderer: any): void;
        refreshView(): void;
        setModel(model: any): void;
    }
}
declare module ag.grid {
    class ValuesSelectionPanel {
        private gridOptionsWrapper;
        private columnController;
        private cColumnList;
        private layout;
        private popupService;
        private dragAndDropService;
        constructor(columnController: ColumnController, gridOptionsWrapper: GridOptionsWrapper, popupService: PopupService, eventService: EventService, dragAndDropService: DragAndDropService);
        getLayout(): any;
        private columnsChanged();
        addDragSource(dragSource: any): void;
        private cellRenderer(params);
        private setupComponents();
        private beforeDropListener(newItem);
    }
}
declare module ag.grid {
    class VerticalStack {
        isLayoutPanel: any;
        childPanels: any;
        eGui: any;
        constructor();
        addPanel(panel: any, height: any): void;
        getGui(): any;
        doLayout(): void;
    }
}
declare module ag.grid {
    class ToolPanel {
        layout: any;
        constructor();
        init(columnController: any, inMemoryRowController: any, gridOptionsWrapper: GridOptionsWrapper, popupService: PopupService, eventService: EventService, dragAndDropService: DragAndDropService): void;
    }
}
declare module ag.grid {
    interface GridOptions {
        virtualPaging?: boolean;
        toolPanelSuppressGroups?: boolean;
        toolPanelSuppressValues?: boolean;
        rowsAlreadyGrouped?: boolean;
        suppressRowClickSelection?: boolean;
        suppressCellSelection?: boolean;
        sortingOrder?: string[];
        suppressMultiSort?: boolean;
        suppressHorizontalScroll?: boolean;
        unSortIcon?: boolean;
        rowBuffer?: number;
        enableColResize?: boolean;
        enableCellExpressions?: boolean;
        enableSorting?: boolean;
        enableServerSideSorting?: boolean;
        enableFilter?: boolean;
        enableServerSideFilter?: boolean;
        colWidth?: number;
        suppressMenuHide?: boolean;
        singleClickEdit?: boolean;
        debug?: boolean;
        icons?: any;
        angularCompileRows?: boolean;
        angularCompileFilters?: boolean;
        angularCompileHeaders?: boolean;
        suppressLoadingOverlay?: boolean;
        suppressNoRowsOverlay?: boolean;
        suppressAutoSize?: boolean;
        suppressParentsInRowNodes?: boolean;
        localeText?: any;
        localeTextFunc?: Function;
        suppressScrollLag?: boolean;
        groupSuppressAutoColumn?: boolean;
        groupSelectsChildren?: boolean;
        groupHideGroupColumns?: boolean;
        groupIncludeFooter?: boolean;
        groupUseEntireRow?: boolean;
        groupSuppressRow?: boolean;
        groupSuppressBlankHeader?: boolean;
        forPrint?: boolean;
        groupColumnDef?: any;
        context?: any;
        rowStyle?: any;
        rowClass?: any;
        groupDefaultExpanded?: number;
        slaveGrids?: GridOptions[];
        rowSelection?: string;
        rowDeselection?: boolean;
        overlayLoadingTemplate?: string;
        overlayNoRowsTemplate?: string;
        checkboxSelection?: Function;
        rowHeight?: number;
        headerCellTemplate?: string;
        rowData?: any[];
        floatingTopRowData?: any[];
        floatingBottomRowData?: any[];
        showToolPanel?: boolean;
        columnDefs?: any[];
        datasource?: any;
        headerHeight?: number;
        groupRowInnerRenderer?(params: any): void;
        groupRowRenderer?: Function | Object;
        isScrollLag?(): boolean;
        isExternalFilterPresent?(): boolean;
        doesExternalFilterPass?(node: RowNode): boolean;
        getRowStyle?: Function;
        getRowClass?: Function;
        getRowHeight?: Function;
        headerCellRenderer?: any;
        groupAggFunction?(nodes: any[]): any;
        getBusinessKeyForNode?(node: RowNode): string;
        getHeaderCellTemplate?: (params: any) => string | HTMLElement;
        onReady?(params: any): void;
        onModelUpdated?(): void;
        onCellClicked?(params: any): void;
        onCellDoubleClicked?(params: any): void;
        onCellContextMenu?(params: any): void;
        onCellValueChanged?(params: any): void;
        onCellFocused?(params: any): void;
        onRowSelected?(params: any): void;
        onRowDeselected?(params: any): void;
        onSelectionChanged?(): void;
        onBeforeFilterChanged?(): void;
        onAfterFilterChanged?(): void;
        onFilterModified?(): void;
        onBeforeSortChanged?(): void;
        onAfterSortChanged?(): void;
        onVirtualRowRemoved?(params: any): void;
        onRowClicked?(params: any): void;
        onRowDoubleClicked?(params: any): void;
        onGridSizeChanged?(params: any): void;
        api?: GridApi;
        columnApi?: ColumnApi;
    }
}
declare module ag.grid {
    class GridApi {
        private grid;
        private rowRenderer;
        private headerRenderer;
        private filterManager;
        private columnController;
        private inMemoryRowController;
        private selectionController;
        private gridOptionsWrapper;
        private gridPanel;
        private valueService;
        private masterSlaveService;
        private eventService;
        private floatingRowModel;
        private csvCreator;
        constructor(grid: Grid, rowRenderer: RowRenderer, headerRenderer: HeaderRenderer, filterManager: FilterManager, columnController: ColumnController, inMemoryRowController: InMemoryRowController, selectionController: SelectionController, gridOptionsWrapper: GridOptionsWrapper, gridPanel: GridPanel, valueService: ValueService, masterSlaveService: MasterSlaveService, eventService: EventService, floatingRowModel: FloatingRowModel);
        /** Used internally by grid. Not intended to be used by the client. Interface may change between releases. */
        __getMasterSlaveService(): MasterSlaveService;
        getDataAsCsv(params?: CsvExportParams): string;
        exportDataAsCsv(params?: CsvExportParams): void;
        setDatasource(datasource: any): void;
        onNewDatasource(): void;
        setRowData(rowData: any): void;
        setRows(rows: any): void;
        onNewRows(): void;
        setFloatingTopRowData(rows: any[]): void;
        setFloatingBottomRowData(rows: any[]): void;
        onNewCols(): void;
        setColumnDefs(colDefs: ColDef[]): void;
        unselectAll(): void;
        refreshRows(rowNodes: RowNode[]): void;
        refreshCells(rowNodes: RowNode[], colIds: string[]): void;
        rowDataChanged(rows: any): void;
        refreshView(): void;
        softRefreshView(): void;
        refreshGroupRows(): void;
        refreshHeader(): void;
        isAnyFilterPresent(): boolean;
        isAdvancedFilterPresent(): boolean;
        isQuickFilterPresent(): boolean;
        getModel(): any;
        onGroupExpandedOrCollapsed(refreshFromIndex: any): void;
        expandAll(): void;
        collapseAll(): void;
        addVirtualRowListener(eventName: string, rowIndex: number, callback: Function): void;
        setQuickFilter(newFilter: any): void;
        selectIndex(index: any, tryMulti: any, suppressEvents: any): void;
        deselectIndex(index: number, suppressEvents?: boolean): void;
        selectNode(node: any, tryMulti?: boolean, suppressEvents?: boolean): void;
        deselectNode(node: any, suppressEvents?: boolean): void;
        selectAll(): void;
        deselectAll(): void;
        recomputeAggregates(): void;
        sizeColumnsToFit(): void;
        showLoadingOverlay(): void;
        showNoRowsOverlay(): void;
        hideOverlay(): void;
        showLoading(show: any): void;
        isNodeSelected(node: any): boolean;
        getSelectedNodesById(): {
            [nodeId: number]: RowNode;
        };
        getSelectedNodes(): RowNode[];
        getSelectedRows(): any[];
        getBestCostNodeSelection(): any;
        getRenderedNodes(): any[];
        ensureColIndexVisible(index: any): void;
        ensureIndexVisible(index: any): void;
        ensureNodeVisible(comparator: any): void;
        forEachInMemory(callback: Function): void;
        forEachNode(callback: Function): void;
        forEachNodeAfterFilter(callback: Function): void;
        forEachNodeAfterFilterAndSort(callback: Function): void;
        getFilterApiForColDef(colDef: any): any;
        getFilterApi(key: any): any;
        getColumnDef(key: any): ColDef;
        onFilterChanged(): void;
        setSortModel(sortModel: any): void;
        getSortModel(): any;
        setFilterModel(model: any): void;
        getFilterModel(): any;
        getFocusedCell(): any;
        setFocusedCell(rowIndex: any, colIndex: any): void;
        setHeaderHeight(headerHeight: number): void;
        showToolPanel(show: any): void;
        isToolPanelShowing(): boolean;
        doLayout(): void;
        getValue(colDef: ColDef, data: any, node: any): any;
        addEventListener(eventType: string, listener: Function): void;
        addGlobalListener(listener: Function): void;
        removeEventListener(eventType: string, listener: Function): void;
        removeGlobalListener(listener: Function): void;
        dispatchEvent(eventType: string, event?: any): void;
        refreshRowGroup(): void;
        destroy(): void;
    }
}
declare module ag.grid {
    class ValueService {
        private gridOptionsWrapper;
        private expressionService;
        private columnController;
        init(gridOptionsWrapper: GridOptionsWrapper, expressionService: ExpressionService, columnController: ColumnController): void;
        getValue(colDef: ColDef, data: any, node: any): any;
        private getValueUsingField(data, field);
        private executeValueGetter(valueGetter, data, colDef, node);
        private getValueCallback(data, node, field);
    }
}
declare module ag.grid {
    class ColumnUtils {
        private gridOptionsWrapper;
        init(gridOptionsWrapper: GridOptionsWrapper): void;
        calculateColInitialWidth(colDef: any): number;
        deptFirstAllColumnTreeSearch(tree: ColumnGroupChild[], callback: (treeNode: ColumnGroupChild) => void): void;
        deptFirstDisplayedColumnTreeSearch(tree: ColumnGroupChild[], callback: (treeNode: ColumnGroupChild) => void): void;
    }
}
declare module ag.grid {
    class Grid {
        static VIRTUAL_ROW_REMOVED: string;
        static VIRTUAL_ROW_SELECTED: string;
        private virtualRowListeners;
        private gridOptions;
        private gridOptionsWrapper;
        private inMemoryRowController;
        private doingVirtualPaging;
        private paginationController;
        private virtualPageRowController;
        private floatingRowModel;
        private finished;
        private selectionController;
        private columnController;
        private rowRenderer;
        private headerRenderer;
        private filterManager;
        private valueService;
        private masterSlaveService;
        private eventService;
        private dragAndDropService;
        private toolPanel;
        private gridPanel;
        private eRootPanel;
        private toolPanelShowing;
        private doingPagination;
        private usingInMemoryModel;
        private rowModel;
        private windowResizeListener;
        private eUserProvidedDiv;
        private logger;
        constructor(eGridDiv: any, gridOptions: any, globalEventListener?: Function, $scope?: any, $compile?: any, quickFilterOnScope?: any);
        private decideStartingOverlay();
        private addWindowResizeListener();
        getRowModel(): any;
        private periodicallyDoLayout();
        private setupComponents($scope, $compile, eUserProvidedDiv, globalEventListener);
        private onColumnChanged(event);
        refreshRowGroup(): void;
        private onIndividualColumnResized(column);
        showToolPanel(show: any): void;
        isToolPanelShowing(): boolean;
        isUsingInMemoryModel(): boolean;
        setDatasource(datasource?: any): void;
        private refreshHeaderAndBody();
        destroy(): void;
        onQuickFilterChanged(newFilter: any): void;
        onFilterModified(): void;
        onFilterChanged(): void;
        onRowClicked(multiSelectKeyPressed: boolean, rowIndex: number, node: RowNode): void;
        showLoadingOverlay(): void;
        showNoRowsOverlay(): void;
        hideOverlay(): void;
        private setupColumns();
        updateModelAndRefresh(step: any, refreshFromIndex?: any): void;
        setRowData(rows?: any, firstId?: any): void;
        ensureNodeVisible(comparator: any): void;
        getFilterModel(): any;
        setFocusedCell(rowIndex: any, colIndex: any): void;
        getSortModel(): any;
        setSortModel(sortModel: any): void;
        onSortingChanged(): void;
        addVirtualRowListener(eventName: string, rowIndex: number, callback: Function): void;
        onVirtualRowSelected(rowIndex: number, selected: boolean): void;
        onVirtualRowRemoved(rowIndex: number): void;
        private removeVirtualCallbacksForRow(rowIndex);
        setColumnDefs(colDefs?: ColDef[]): void;
        updateBodyContainerWidthAfterColResize(): void;
        updatePinnedColContainerWidthAfterColResize(): void;
        doLayout(): void;
    }
}
declare module ag.grid {
    class AgGridNg2 {
        private elementDef;
        private _agGrid;
        private _initialised;
        private gridOptions;
        private api;
        private columnApi;
        modelUpdated: any;
        cellClicked: any;
        cellDoubleClicked: any;
        cellContextMenu: any;
        cellValueChanged: any;
        cellFocused: any;
        rowSelected: any;
        rowDeselected: any;
        selectionChanged: any;
        beforeFilterChanged: any;
        afterFilterChanged: any;
        filterModified: any;
        beforeSortChanged: any;
        afterSortChanged: any;
        virtualRowRemoved: any;
        rowClicked: any;
        rowDoubleClicked: any;
        ready: any;
        gridSizeChanged: any;
        rowGroupOpened: any;
        columnEverythingChanged: any;
        columnRowGroupChanged: any;
        columnValueChanged: any;
        columnMoved: any;
        columnVisible: any;
        columnGroupOpened: any;
        columnResized: any;
        columnPinnedCountChanged: any;
        virtualPaging: boolean;
        toolPanelSuppressGroups: boolean;
        toolPanelSuppressValues: boolean;
        rowsAlreadyGrouped: boolean;
        suppressRowClickSelection: boolean;
        suppressCellSelection: boolean;
        sortingOrder: string[];
        suppressMultiSort: boolean;
        suppressHorizontalScroll: boolean;
        unSortIcon: boolean;
        rowHeight: number;
        rowBuffer: number;
        enableColResize: boolean;
        enableCellExpressions: boolean;
        enableSorting: boolean;
        enableServerSideSorting: boolean;
        enableFilter: boolean;
        enableServerSideFilter: boolean;
        colWidth: number;
        suppressMenuHide: boolean;
        debug: boolean;
        icons: any;
        angularCompileRows: boolean;
        angularCompileFilters: boolean;
        angularCompileHeaders: boolean;
        localeText: any;
        localeTextFunc: Function;
        groupSuppressAutoColumn: boolean;
        groupSelectsChildren: boolean;
        groupHideGroupColumns: boolean;
        groupIncludeFooter: boolean;
        groupUseEntireRow: boolean;
        groupSuppressRow: boolean;
        groupSuppressBlankHeader: boolean;
        groupColumnDef: any;
        forPrint: boolean;
        context: any;
        rowStyle: any;
        rowClass: any;
        headerCellRenderer: any;
        groupDefaultExpanded: number;
        slaveGrids: GridOptions[];
        rowSelection: string;
        rowDeselection: boolean;
        headerCellTemplate: string;
        rowData: any[];
        floatingTopRowData: any[];
        floatingBottomRowData: any[];
        showToolPanel: boolean;
        groupAggFunction: (nodes: any[]) => void;
        columnDefs: any[];
        datasource: any;
        pinnedColumnCount: number;
        quickFilterText: string;
        headerHeight: number;
        constructor(elementDef: any);
        ngOnInit(): void;
        ngOnChanges(changes: any): void;
        ngOnDestroy(): void;
        private globalEventListener(eventType, event);
    }
    function initialiseAgGridWithAngular2(ng: any): void;
}
declare module ag.grid {
    function initialiseAgGridWithAngular1(angular: any): void;
}
declare module ag.grid {
}
declare var __RANDOM_GLOBAL_VARIABLE_FSKJFHSKJFHKSDAJF: any;
declare module ag.grid {
    interface Filter {
        getGui(): any;
        isFilterActive(): boolean;
        doesFilterPass(params: any): boolean;
        afterGuiAttached?(params?: {
            hidePopup?: Function;
        }): void;
        onNewRowsLoaded?(): void;
    }
}
