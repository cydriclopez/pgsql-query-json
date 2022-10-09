import { Component, OnInit } from '@angular/core';
import { NodeService } from '../services/nodeservice';
import { MessageService } from 'primeng/api';

@Component({
  selector: 'app-treedemo',
  templateUrl: './treedemo.component.html',
  styleUrls: ['./treedemo.component.css'],
  providers: [MessageService]
})
export class TreedemoComponent implements OnInit {

    constructor(
        private nodeService: NodeService,
        private messageService: MessageService
    ) { }

    // Read-only access to tree data. Components are
    // for UI display. Application state, data, and
    // logic must be off-loaded to a service.
    public get treeNodes() {
        return this.nodeService.treeNodes;
    }

    ngOnInit() { }

    expandAll() {
        this.nodeService.treeNodes.forEach( node => {
            this.nodeService.expandRecursive(node, true);
        });
    }

    collapseAll() {
        this.nodeService.treeNodes.forEach( node => {
            this.nodeService.expandRecursive(node, false);
        });
    }

    // Save field toexpand = expanded so we can
    // revert to expanded or collapsed modes.
    saveToexpand(event) {
        this.nodeService.saveToexpand(event);
    }

    // Save tree component data to server
    postJsonData() {
        this.nodeService.postJsonString();

        // Show message for feedback
        this.messageService.add({
            severity:'success',
            summary: 'Save',
            detail: 'Saved data to database'
        });
    }

    // Read tree component tree from server
    readJsonData() {
        this.nodeService.getTreeNodes();

        // Show message for feedback
        this.messageService.add({
            severity:'success',
            summary: 'Read',
            detail: 'Read data from database'
        });
    }
}
