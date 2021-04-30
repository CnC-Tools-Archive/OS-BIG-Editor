(*******************************************************************************
 * Author      Banshee
 *
 * Date        15/03/2007
 *
 * Copyright
 ******************************************************************************)
// I am creating this library because the way that FindNode function was
// checking for repetitive items had an exponential complextity, making
// files like DemStreams.big take minutes (plural) to load here.

unit TreeViewDoubleItemQuickChecker;

interface

uses
   BasicDataTypes,ComCtrls;

type
   PTreeNode = ^TTreeNode;
   PTreeViewItemOrganizerUnit = ^TTreeViewItemOrganizerUnit;
   TTreeViewItemOrganizerUnit = record
      Name : string;
      Parent : int32;
      MyNode : PTreeNode;
      MyParent : PTreeNode;
      FirstChild : int32;
   end;

   TTreeViewItemOrganizer = class
   private
      Units : array of PTreeViewItemOrganizerUnit;
      Parents : array of PTreeViewItemOrganizerUnit;
      Count : uint32;
      ParentCount : uint32;
   public
      // Constructors and Destructors;
      constructor Create;
      // Adds
      function AddNode(const _parent : string; const _name : string): boolean;
      // Removes
      // Gets
      // Sets
   end;


implementation

// Constructors
constructor TTreeViewItemOrganizer.Create;
begin
   Count := 0;
   ParentCount := 0;
   SetLength(Units,Count);
   SetLength(Parents,ParentCount);
end;

// Adds
function TTreeViewItemOrganizer.AddNode(const _parent : string; const _name : string): boolean;
begin
   // First, we check if the element exists.
   // To do that, we have two situations. 1) We have items; 2) We don't have items
   if (Count > 0) then
   begin
      // Here we have items.

   end;

   // Then, we add the new item and move the others to keep it sorted.

end;

end.
