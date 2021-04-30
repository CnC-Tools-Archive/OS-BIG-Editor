(*******************************************************************************
 * Author  Banshee
 *
 * Date    09/02/2008
 *
 * Copyright
 ******************************************************************************)
unit uSelectedNodes;

interface

uses
   ComCtrls, BasicDataTypes, BasicConstants;

type
   CSelectedNodes = class
      public
         // Variables
         Nodes : array of TTreeNode;
         // Constructors
         constructor Create;
         destructor Destroy; override;
         procedure Reset;
         // Gets
         function GetNumNodes: uint32;
         // Adds
         function AddNode(const _Node: TTreeNode): boolean;
   end;

implementation

   // Constructors
   constructor CSelectedNodes.Create;
   begin
      Reset;
   end;

   destructor CSelectedNodes.Destroy;
   begin
      Reset;
      inherited Destroy;
   end;

   procedure CSelectedNodes.Reset;
   var
      i : uint32;
   begin
      if High(Nodes) >= 0 then
      begin
         for i := Low(Nodes) to High(Nodes) do
            if Assigned(Nodes[i]) then
               Nodes[i].Cut := false;
      end;
      SetLength(Nodes,0);
   end;

   // Gets
   function CSelectedNodes.GetNumNodes;
   begin
      Result := High(Nodes) + 1;
   end;

   // Adds
   function CSelectedNodes.AddNode(const _Node: TTreeNode): boolean;
   begin
      Result := (_Node <> nil);
      if Result then
      begin
         SetLength(Nodes,High(Nodes)+2);
         Nodes[High(Nodes)] := _Node;
      end;
   end;
end.
