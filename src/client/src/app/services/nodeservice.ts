import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { TreeNode } from 'primeng/api';

export const httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
    })
};

export interface TreeNode2 extends TreeNode {
    toexpand?:      boolean;
    /**
     * Hint: You can expand this to implement whatever
     * data you want persisted in this recursive structure
     * and to support whatever operation you want done on
     * the client or in the server.
     */
}

// ***********************************************************
// This JsonData interface should agree with Go server-side
export interface JsonData {
    data:   string;
} // *********************************************************
// Go server-side struct in src/server/treedata/treedata.go
// type JsonData struct {
//     Data string `json:"data"`
// }
// ***********************************************************

@Injectable({
    providedIn: 'root',
})
export class NodeService {

    treeNodes: TreeNode2[];

    constructor(private http: HttpClient) {
        this.getTreeNodes();
    }

    getTreeNodes() {
        this.loadTreeNodes().then(treeNodes => {
            this.treeNodes = treeNodes;

            // Restore expanded/collapsed nodes
            this.treeNodes.forEach( node => {
                this.restoreRecursive(node);
            });

        })
    }

    loadTreeNodes() {
        return this.http.get<any>('/api/getsidemenudata/')
          .toPromise()
          .then(res => <TreeNode2[]>res.data);
    }

    // Recourse thru JSON data to save toexpand = expanded.
    // This is so when we refresh the data, those nodes that were
    // expanded we can expand, in this.restoreRecursive(), again by
    // reversing the expression expanded = toexpand.
    saveToexpand(node:TreeNode2) {
        node.toexpand = node.expanded;
        if (node.children) {
            node.children.forEach(childNode => {
                this.saveToexpand(childNode);
            });
        }
    }

    // Restore expanded or collapsed nodes
    restoreRecursive(node: TreeNode2) {
        node.expanded = node.toexpand;
        if (node.children) {
            node.children.forEach( childNode => {
                this.restoreRecursive(childNode);
            });
        }
    }

    // Expand or collapse all nodes
    expandRecursive(node: TreeNode2, isExpand: boolean) {
        node.expanded = node.toexpand = isExpand;
        if (node.children) {
            node.children.forEach( childNode => {
                this.expandRecursive(childNode, isExpand);
            });
        }
    }

    postJsonString() {
        // First recourse thru JSON data to save toexpand = expanded.
        // The field expanded is a Primeng tree component switch that
        // we cannot persist to the db. We need the toexpand field
        // for that purpose. It's why we extended TreeNode with:
        //    export interface TreeNode2 extends TreeNode { }
        this.treeNodes.forEach(node => {
            this.saveToexpand(node);
        });

        // The JSON.stringify replacer array parameter will flatten the json
        // to prevent circular references. Fields 'key', 'parent', and 'leaf'
        // are filtered-out and inferred from the json structure. PostgreSQL
        // can traverse thru the json and fill-in these fields from the structure.
        const json = JSON.stringify(this.treeNodes,
            [
                'label', 'icon', 'expandedIcon', 'collapsedIcon',
                'data', 'children', 'toexpand', 'group_id'
            ]
        );

        const jsonData: JsonData = { data: json };
        this.http.post<any>('/api/postjsonstring', jsonData, httpOptions)
            .subscribe();
    }

}
