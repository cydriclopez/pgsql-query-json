import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { InputNumberModule } from 'primeng/inputnumber';
import { ButtonModule } from 'primeng/button';
import { TableModule } from 'primeng/table';
import { DialogModule } from 'primeng/dialog';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { DropdownModule } from 'primeng/dropdown';
import { RadioButtonModule } from 'primeng/radiobutton';
import { RatingModule } from 'primeng/rating';
import { ToolbarModule } from 'primeng/toolbar';
import { ConfirmationService } from 'primeng/api';
import { AppComponent } from './app.component';

import { RouterModule, Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { TreedemoComponent } from './treedemo/treedemo.component';
import { TreeModule } from 'primeng/tree';
import { ToastModule } from 'primeng/toast';

@NgModule({
    declarations: [
        AppComponent,
        HomeComponent,
        TreedemoComponent
    ],
    imports: [
        BrowserModule,
        BrowserAnimationsModule,
        FormsModule,
        TableModule,
        HttpClientModule,
        InputTextModule,
        DialogModule,
        ToolbarModule,
        ConfirmDialogModule,
        RatingModule,
        InputNumberModule,
        InputTextareaModule,
        RadioButtonModule,
        DropdownModule,
        ButtonModule,
        TreeModule,
        ToastModule,

        RouterModule.forRoot([
            {
                path: '', component: HomeComponent,
                children: [
                    {path: '', component: AppComponent},
                    {path: 'home', component: AppComponent},
                    {path: 'tree', component: TreedemoComponent},
                ]
            },
            {path: '**', redirectTo: ''},
        ], {useHash: true})

    ],
    exports: [RouterModule],
    providers: [ConfirmationService],
    bootstrap: [HomeComponent]
})
export class AppModule { }
